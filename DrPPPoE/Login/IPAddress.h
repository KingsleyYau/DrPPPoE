/*
 *  IPAddress.h
 *  DrCOMClientWS
 *
 *  Created by Keqin Su on 11-5-6.
 *  Copyright 2011 City Hotspot Co., Ltd. All rights reserved.
 *
 */

#define MAXADDRS    32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
int GetIPAddresses();
int GetHWAddresses();
