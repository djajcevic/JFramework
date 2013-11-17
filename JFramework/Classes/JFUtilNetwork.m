//
//  JFUtilNetwork.m
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 28.2.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import "JFUtilNetwork.h"

#import "NSString+JF.h"

#define    min(a,b)    ((a) < (b) ? (a) : (b))
#define    max(a,b)    ((a) > (b) ? (a) : (b))

#define BUFFERSIZE    4000

char *if_names[MAXADDRS];
char *ip_names[MAXADDRS];
char *hw_addrs[MAXADDRS];
unsigned long ip_addrs[MAXADDRS];

static int nextAddr = 0;

void InitAddresses() {
    int i;
    for (i = 0; i < MAXADDRS; ++i) {
        if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
        ip_addrs[i]                             = 0;
    }
}

void FreeAddresses() {
    int i;
    for (i = 0; i < MAXADDRS; ++i) {
        if (if_names[i] != 0) free (if_names[i]);
        if (ip_names[i] != 0) free (ip_names[i]);
        if (hw_addrs[i] != 0) free (hw_addrs[i]);
        ip_addrs[i] = 0;
    }
    InitAddresses ();
}

void GetIPAddresses() {
    int  i, len, flags;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifconf                  ifc;
    struct ifreq *ifr, ifrcopy;
    struct sockaddr_in *sin;

    char temp[80];

    int sockfd;

    for (i = 0; i < MAXADDRS; ++i) {
        if_names[i] = ip_names[i] = NULL;
        ip_addrs[i]               = 0;
    }

    sockfd = socket (AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror ("socket failed");
        return;
    }

    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;

    if (ioctl (sockfd, SIOCGIFCONF, &ifc) < 0) {
        perror ("ioctl error");
        return;
    }

    lastname[0] = 0;

    for (ptr = buffer; ptr < buffer + ifc.ifc_len;) {
        ifr = (struct ifreq *) ptr;
        len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
        ptr += sizeof(ifr->ifr_name) + len;    // for next one in buffer

        if (ifr->ifr_addr.sa_family != AF_INET) {
            continue;    // ignore if not desired address family
        }

        if ((cptr = (char *) strchr (ifr->ifr_name, ':')) != NULL) {
            *cptr = 0;        // replace colon will null
        }

        if (strncmp (lastname, ifr->ifr_name, IFNAMSIZ) == 0) {
            continue;    /* already processed this interface */
        }

        memcpy(lastname, ifr->ifr_name, IFNAMSIZ);

        ifrcopy = *ifr;
        ioctl (sockfd, SIOCGIFFLAGS, &ifrcopy);
        flags = ifrcopy.ifr_flags;
        if ((flags & IFF_UP) == 0) {
            continue;    // ignore if interface not up
        }

        if_names[nextAddr] = (char *) malloc (strlen (ifr->ifr_name) + 1);
        if (if_names[nextAddr] == NULL) {
            return;
        }
        strcpy(if_names[nextAddr], ifr->ifr_name);

        sin = (struct sockaddr_in *) &ifr->ifr_addr;
        strcpy(temp, inet_ntoa (sin->sin_addr));

        ip_names[nextAddr] = (char *) malloc (strlen (temp) + 1);
        if (ip_names[nextAddr] == NULL) {
            return;
        }
        strcpy(ip_names[nextAddr], temp);

        ip_addrs[nextAddr] = sin->sin_addr.s_addr;

        ++nextAddr;
    }

    close (sockfd);
}

void GetHWAddresses() {
    struct ifconf ifc;
    struct ifreq *ifr;
    int  i, sockfd;
    char buffer[BUFFERSIZE], *cp, *cplim;
    char                          temp[80];

    for (i = 0; i < MAXADDRS; ++i) {
        hw_addrs[i] = NULL;
    }

    sockfd = socket (AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror ("socket failed");
        return;
    }

    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;

    if (ioctl (sockfd, SIOCGIFCONF, (char *) &ifc) < 0) {
        perror ("ioctl error");
        close (sockfd);
        return;
    }

    ifr = ifc.ifc_req;

    cplim = buffer + ifc.ifc_len;

    for (cp = buffer; cp < cplim;) {
        ifr = (struct ifreq *) cp;
        if (ifr->ifr_addr.sa_family == AF_LINK) {
            struct sockaddr_dl *sdl = (struct sockaddr_dl *) &ifr->ifr_addr;
            int a, b, c, d, e, f;
            int i;

            strcpy(temp, (char *) ether_ntoa ((const struct ether_addr *) LLADDR (sdl)));
            sscanf (temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);

            sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X", a, b, c, d, e, f);

            NSLog(@"%@", [[NSString alloc] initWithCString:temp encoding:NSUTF8StringEncoding]);

            for (i = 0; i < MAXADDRS; ++i) {
                if ((if_names[i] != NULL) && (strcmp (ifr->ifr_name, if_names[i]) == 0)) {
                    if (hw_addrs[i] == NULL) {
                        hw_addrs[i] = (char *) malloc (strlen (temp) + 1);
                        strcpy(hw_addrs[i], temp);
                        break;
                    }
                }
            }
        }
        cp += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }

    close (sockfd);
}

@implementation JFUtilNetwork

+ (NSString *)MAC
{
    int mgmtInfoBase[6];
    char *msgBuffer               = NULL;
    size_t        length;
    unsigned char macAddress[6];
    struct if_msghdr   *interfaceMsgStruct;
    struct sockaddr_dl *socketStruct;
    NSString           *errorFlag = NULL;

    GetHWAddresses();

    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces

    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex ("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else {
        // Get the size of the data available (store in len)
        if (sysctl (mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else {
            // Alloc memory based on above call
            if ((msgBuffer = malloc (length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else {
                // Get system information, store in buffer
                if (sysctl (mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }

    // Befor going any further...
    if (errorFlag != NULL) {
        NSLog (@"Error: %@", errorFlag);
        return errorFlag;
    }

    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;

    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);

    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);

    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                                            macAddress[0], macAddress[1], macAddress[2],
                                                            macAddress[3], macAddress[4], macAddress[5]];

    NSLog(@"Mac Address: %@", macAddressString);

    // Release the buffer memory
    free (msgBuffer);

    return macAddressString;
}

+ (NSString *)hashedMAC
{
    NSString *input = [JFUtilNetwork MAC];

    NSString *sha1 = [input sha1];

    return sha1;
}

+ (BOOL)internetAvailable
{
    GetIPAddresses ();
    BOOL available = YES;

    int addresCount = 0;
    char *address = nil;
    while ((address = ip_names[addresCount]) != nil) {
        addresCount++;
    }

    FreeAddresses ();

    available = addresCount > 1;

    return available;
}

static int downloadCount;

+(void)showNetworkIndicator
{
    if (NO == [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    else {

    }
    downloadCount++;
}

+(void)hideNetworkIndicator
{
    downloadCount--;
    if (downloadCount <= 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        downloadCount = 0;
    }
}

@end
