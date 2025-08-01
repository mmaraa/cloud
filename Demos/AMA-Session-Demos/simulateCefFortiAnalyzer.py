#!/usr/bin/env python3
import argparse
import socket
import random
import uuid
import time
from datetime import datetime

MONTH_ABBR = ["Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

def fmt_syslog_timestamp(dt: datetime) -> str:
    # Syslog timestamp: "Mmm dd HH:MM:SS" with space-padded day
    mon = MONTH_ABBR[dt.month - 1]
    day = f"{dt.day:2d}"
    return f"{mon} {day} {dt.strftime('%H:%M:%S')}"

def fmt_cef_start_timestamp(dt: datetime) -> str:
    # e.g. "Aug 01 2025 12:34:56"
    mon = MONTH_ABBR[dt.month - 1]
    day = f"{dt.day:02d}"
    return f"{mon} {day} {dt.year} {dt.strftime('%H:%M:%S')}"

def random_private_src_ip():
    # use 192.168.x.x
    return f"192.168.{random.randint(0,255)}.{random.randint(1,254)}"

def random_public_dst_ip():
    # avoid common reserved blocks for simplicity; choose first octet from 1-223 excluding private/loopback (10,127,169,172,192)
    forbidden = {10, 127, 169, 172, 192}
    first = random.choice([i for i in range(1, 224) if i not in forbidden])
    return f"{first}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}"

def build_syslog_message(include_pri: bool, pri_header: str, dvchost: str) -> str:
    now = datetime.now()
    syslog_ts = fmt_syslog_timestamp(now)
    cef_start = fmt_cef_start_timestamp(now)
    eventtime = int(time.time() * 1_000_000_000 + random.randint(0, 999_999))  # large number similar to original
    src_ip = random_private_src_ip()
    dst_ip = random_public_dst_ip()
    src_port = random.randint(1025, 65535)
    dst_port = 443  # keep HTTPS
    poluuid = str(uuid.uuid4())
    srcuuid = str(uuid.uuid4())
    dstuuid = str(uuid.uuid4())
    externalID = random.randint(1_000_000_000, 9_999_999_999)
    policyid = random.randint(10000, 99999)
    # domain for dhost
    dhost = f"anonymized{random.randint(1000,9999)}.com"

    # Build CEF extension part
    extension_parts = [
        f"start={cef_start}",
        "logver=702081639",  # static to keep flavor similar
        "deviceExternalId=FG10011111111",
        f"dvchost={dvchost}",
        "vd=root",
        f"eventtime={eventtime}",
        "tz=+0200",
        "logid=0317013312",
        "cat=utm",
        "subtype=webfilter",
        "eventtype=ftgd_allow",
        "deviceSeverity=notice",
        f"policyid={policyid}",
        f"poluuid={poluuid}",
        "policytype=policy",
        f"externalID={externalID}",
        f"src={src_ip}",
        f"spt={src_port}",
        "srccountry=Reserved",
        "deviceInboundInterface=port1.24",
        "srcintfrole=lan",
        f"srcuuid={srcuuid}",
        f"dst={dst_ip}",
        f"dpt={dst_port}",
        "dstcountry=United States",
        "deviceOutboundInterface=wan1",
        "dstintfrole=wan",
        f"dstuuid={dstuuid}",
        "proto=6",
        "app=HTTPS",
        f"dhost={dhost}",
        "profile=web-custom",
        "act=passthrough",
        "reqtype=direct",
        "request=https://browser.events.data.microsoft.com/",
        "out=1743",
        "in=0",
        "direction=outgoing",
        "msg=URL belongs to an allowed category in policy",
        "ratemethod=domain",
        "cat=52",
        "requestContext=Information Technology",
        'tz="+0200"'  # note the original had tz quoted here
    ]
    extension = " ".join(extension_parts)

    cef_header = "CEF:0|Fortinet|FortiGate-100F|7.2.8,build1639 (GA)|0317013312|webfilter utm passthrough|5|"
    body = f"{cef_header}{extension}"

    prefix = ""
    if include_pri:
        prefix = pri_header
        # ensure there's no accidental double angle brackets
    message = f"{prefix}{syslog_ts} {dvchost} {body}"
    return message

def send_message(message: str, server: str, port: int, protocol: str, sock=None):
    if protocol.lower() == "udp":
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.sendto(message.encode("utf-8"), (server, port))
    else:
        # TCP: reuse connection if provided
        if sock is None:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(5)
                s.connect((server, port))
                s.sendall(message.encode("utf-8"))
        else:
            sock.sendall(message.encode("utf-8"))

def main():
    parser = argparse.ArgumentParser(description="Generate and send fake FortiGate-like CEF syslog messages.")
    parser.add_argument("server", help="Syslog server IP or hostname")
    parser.add_argument("--port", "-p", type=int, default=514, help="Syslog server port (default 514)")
    parser.add_argument("--protocol", "-P", choices=["udp", "tcp"], default="udp", help="Transport protocol (udp or tcp), default udp")
    parser.add_argument("--include-pri", action="store_true", help="Include PRI header prefix")
    parser.add_argument("--pri-header", help="PRI header to include (e.g. '<13>') — required if --include-pri is set")
    parser.add_argument("--dvchost", default="firewall1", help="Constant dvchost value to use (default: firewall1)")
    parser.add_argument("--count", "-c", type=int, default=1, help="How many messages to send")
    parser.add_argument("--interval", "-i", type=float, default=0, help="Seconds to wait between messages when sending multiple")
    args = parser.parse_args()

    if args.include_pri and not args.pri_header:
        parser.error("--include-pri requires --pri-header to be specified")

    if not args.include_pri and args.pri_header:
        print("Warning: --pri-header provided but --include-pri not set; header will be ignored.")

    tcp_sock = None
    try:
        if args.protocol.lower() == "tcp" and args.count > 0:
            tcp_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            tcp_sock.settimeout(5)
            tcp_sock.connect((args.server, args.port))
        for i in range(args.count):
            msg = build_syslog_message(include_pri=args.include_pri, pri_header=args.pri_header or "", dvchost=args.dvchost)
            # send
            if args.protocol.lower() == "udp":
                send_message(msg, args.server, args.port, "udp")
            else:
                send_message(msg + "\n", args.server, args.port, "tcp", sock=tcp_sock)
            print(f"[{i+1}/{args.count}] Sent: {msg}")
            if i < args.count - 1 and args.interval > 0:
                time.sleep(args.interval)
    finally:
        if tcp_sock:
            tcp_sock.close()

if __name__ == "__main__":
    main()
