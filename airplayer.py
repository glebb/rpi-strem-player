#!/usr/bin/env python
import socket
import select
import sys
import pybonjour
import time

selectedVideo = sys.argv[1]
regtype  = "_airplay._tcp"
timeout  = 5
resolved = []
host = None
queried = []

#
# Data Model for a Air Play Device
#
class AirPlayDevice:
    def __init__(self, interfaceIndex, fullname, hosttarget, port):
        self.interfaceIndex = interfaceIndex
        self.fullname = fullname
        self.hosttarget = hosttarget
        self.port = port;
        self.displayname = hosttarget.replace(".local.", "")
        self.ip = 0

# Defines the Post message to play the selected video
def post_message(sel_vid):
    body = "Content-Location: %s\nStart-Position: 0\n\n" % (sel_vid)
    return "POST /play HTTP/1.1\n" \
           "Content-Length: %d\n"  \
           "User-Agent: MediaControl/1.0\n\n%s" % (len(body), body)

#
# Connecting to the selected AirPlay device
# and sends the video to it
def connect_to_socket(ip, port):
    print "connect to socket"
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ip, port))
    s.send(post_message(selectedVideo))
    var = 1
    print "Press CTRL-C to end."

    timeTrigger = 0
    while var == 1 :  # This constructs an infinite loop
        # keep the socket alive by sending a packet once per second
        curTime = time.time()
        if curTime > timeTrigger:
            s.send("\0")
            timeTrigger = curTime + 1

# Gets the IP from selected device
def query_record_callback(sdRef, flags, interfaceIndex, errorCode, fullname, rrtype, rrclass, rdata, ttl):
    if errorCode == pybonjour.kDNSServiceErr_NoError:
        host.ip = socket.inet_ntoa(rdata)
        queried.append(True)

def resolve_callback(sdRef, flags, interfaceIndex, errorCode, fullname,
                     hosttarget, port, txtRecord):
    if errorCode == pybonjour.kDNSServiceErr_NoError:
        print 'Resolved service:'
        print '  fullname   =', fullname
        print '  hosttarget =', hosttarget
        print '  port       =', port
        global host
        host = AirPlayDevice(interfaceIndex, fullname, hosttarget, port)
        resolved.append(True)


def browse_callback(sdRef, flags, interfaceIndex, errorCode, serviceName,
                    regtype, replyDomain):
    print "browse callback"
    if errorCode != pybonjour.kDNSServiceErr_NoError:
        return

    if not (flags & pybonjour.kDNSServiceFlagsAdd):
        print 'Service removed'
        return

    print 'Service added; resolving'

    resolve_sdRef = pybonjour.DNSServiceResolve(0,
                                                interfaceIndex,
                                                serviceName,
                                                regtype,
                                                replyDomain,
                                                resolve_callback)

    try:
        while not resolved:
            ready = select.select([resolve_sdRef], [], [], timeout)
            if resolve_sdRef not in ready[0]:
                print 'Resolve timed out'
                break
            pybonjour.DNSServiceProcessResult(resolve_sdRef)
        else:
            resolved.pop()
    finally:
        resolve_sdRef.close()

browse_sdRef = pybonjour.DNSServiceBrowse(regtype = regtype,
                                          callBack = browse_callback)
try:
    try:
        while not host:
            ready = select.select([browse_sdRef], [], [])
            if browse_sdRef in ready[0]:
                pybonjour.DNSServiceProcessResult(browse_sdRef)
    except KeyboardInterrupt:
        pass
finally:
    browse_sdRef.close()


query_sdRef = pybonjour.DNSServiceQueryRecord(interfaceIndex = host.interfaceIndex,
                                              fullname = host.hosttarget,
                                              rrtype = pybonjour.kDNSServiceType_A,
                                              callBack = query_record_callback)

try: 
    while not queried:
        ready = select.select([query_sdRef], [], [], timeout)
        if query_sdRef not in ready[0]:
            print "Query not in record"
            break
        pybonjour.DNSServiceProcessResult(query_sdRef)
    else:
        queried.pop()
        
finally:
    query_sdRef.close()


connect_to_socket(host.ip, host.port)
