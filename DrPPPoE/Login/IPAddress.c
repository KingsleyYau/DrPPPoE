/*
 *  IPAddress.c
 *  DrCOMClientWS
 *
 *  Created by Keqin Su on 11-5-6.
 *  Copyright 2011 City Hotspot Co., Ltd. All rights reserved.
 *
 */

#include "IPAddress.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/ethernet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>

#define    min(a,b)    ((a) < (b) ? (a) : (b))
#define    max(a,b)    ((a) > (b) ? (a) : (b))

#define BUFFERSIZE    4000

char *if_names[MAXADDRS];
char *ip_names[MAXADDRS];
char *hw_addrs[MAXADDRS];

void InitAddresses()
{
    for (int i = 0; i < MAXADDRS; ++i) {
        if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
    }
}

void FreeAddresses()
{
    for (int i = 0; i < MAXADDRS; ++i) {
        if (if_names[i] != 0) {
			free(if_names[i]);
			if_names[i] = NULL;
		}
        if (ip_names[i] != 0) {
			free(ip_names[i]);
			ip_names[i] = NULL;
		}
        if (hw_addrs[i] != 0) {
            free(hw_addrs[i]);
            hw_addrs[i] = NULL;
        }    
    }
}

int GetIPAddresses()
{
	int					nextAddr = 0;
    int                 len = 0, flags = 0;
    char                buffer[BUFFERSIZE] = {'\0'}, *ptr = NULL, lastname[IFNAMSIZ] = {'\0'}, *cptr = NULL, temp[80] = {'\0'};
    struct ifconf       ifc;
    struct ifreq        *ifr, ifrcopy;
    struct sockaddr_in  *sin;    
    int					sockfd;
    
    FreeAddresses();
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        return nextAddr;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        return nextAddr;
    }
    
    lastname[0] = 0;
    
    for (ptr = buffer; ptr < buffer + ifc.ifc_len; ) {
        ifr = (struct ifreq *)ptr;
        len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
        ptr += sizeof(ifr->ifr_name) + len;    // for next one in buffer
        
        if (ifr->ifr_addr.sa_family != AF_INET) {
            continue;    // ignore if not desired address family
        }
        
        if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) {
            *cptr = 0;        // replace colon will null
        }
        
        if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) {
            continue;    /* already processed this interface */
        }
        
        memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
        
        ifrcopy = *ifr;
        ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
        flags = ifrcopy.ifr_flags;
        if ((flags & IFF_UP) == 0) {
            continue;    // ignore if interface not up
        }
        
        if_names[nextAddr] = (char *)malloc(strlen(ifr->ifr_name)+1);
        if (if_names[nextAddr] == NULL) {
            return nextAddr;
        }
        strcpy(if_names[nextAddr], ifr->ifr_name);
        
        sin = (struct sockaddr_in *)&ifr->ifr_addr;
        strcpy(temp, inet_ntoa(sin->sin_addr));
        
        ip_names[nextAddr] = (char *)malloc(strlen(temp)+1);
        if (ip_names[nextAddr] == NULL) {
            return nextAddr;
        }
        strcpy(ip_names[nextAddr], temp);
        
        ++nextAddr;
    }
    
    close(sockfd);
	return nextAddr;
}

int GetHWAddresses()
{
    int					nextAddr = 0;
    struct ifconf       ifc;
    struct ifreq        *ifr;
    int                 sockfd = 0;
    char                buffer[BUFFERSIZE] = {'\0'}, *cp = NULL, *cplim = NULL;
    char                temp[80] = {'\0'};
    
    for (int i = 0; i < MAXADDRS; ++i) {
        if (hw_addrs[i] != 0) {
            free(hw_addrs[i]);
            hw_addrs[i] = NULL;
        }    
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        return nextAddr;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, (char *)&ifc) < 0) {
        close(sockfd);
        return nextAddr;
    }
    
    ifr = ifc.ifc_req;
    cplim = buffer + ifc.ifc_len;
    
    for (cp = buffer; cp < cplim; ) {
        ifr = (struct ifreq *)cp;
        if (ifr->ifr_addr.sa_family == AF_LINK) {
            struct sockaddr_dl *sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
            int a = 0, b = 0, c = 0, d = 0, e = 0, f = 0;
            int i = 0;
            
            strcpy(temp, (char *)ether_ntoa((const struct ether_addr *)LLADDR(sdl)));
            sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
            sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
            
            for (i = 0; i < MAXADDRS; ++i) {
                if ((if_names[i] != NULL) && (strcmp(ifr->ifr_name, if_names[i]) == 0)) {
                    if (hw_addrs[i] == NULL) {
                        hw_addrs[i] = (char *)malloc(strlen(temp)+1);
                        strcpy(hw_addrs[i], temp);
                        nextAddr++;
                        break;
                    }
                }
            }
        }
        cp += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }
    
    close(sockfd);
    return nextAddr;
}
