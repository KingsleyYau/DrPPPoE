/*
 * DrppoePlugin.h
 *
 *  Created on: 2014年2月22日
 *      Author: Kingsley Yau
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef DRPPOEPLUGIN_H_
#define DRPPOEPLUGIN_H_

#include "../common/Arithmetic.h"
#include "../common/DrUdpSocket.h"
#include "../common/DrThread.h"
#include "../common/command.h"

#include "DrStepDef.h"
#include "DrAuthStatus.h"

const unsigned long MAX_MODULE_FILE_SIZE = 256 * 1024;
const unsigned long MIN_MODULE_FILE_SIZE = 0;

// 认证步骤
typedef enum DrPPPoEPluginSetp {
	SetpNone,
	SetpSendChallenge,
	SetpChallengeRep,
	SetpSendLogin,
	SendLoginRes,
	SendClientPing,
}DRPPPOEPLUGINSETP;

class DrppoePlugin {
public:
	DrppoePlugin();
	~DrppoePlugin();

	// 启用Dr.COM PPPoE插件
	bool StartDrPPPoEPluginService();
	bool StartDrPPPoEPlugin();
	void StopDrPPPoEPlugin();
	// 获取当前登录状态
	bool GetOnlineStatus();
	// 认证线程是否需要继续运行
	bool IsRunning();
	// 插件服务是否运行
	bool IsServiceRunning();
	// 重置参数
	bool ResetParam();

	// 发送对象
	DrUdpSocket GetUdpSocket();
	void WaitForAuthThread(int second);
	void LockFirstTimeAnti();
	void UnLockFirstTimeAnti();

	// PPPoE服务器地址
	string GetPPPoEServerAddress();
	string GetServerAddress();
	void SetServerAddress(string ip);

	// 认证步骤
	int DrcomDialExtProtoSendChallenge(); 									// 第1步,发起认证请求
	void OnDrcomDialExtProtoHandler(char *pBuffer, int iLen);				// 接收服务器响应处理
	int DrcomDialExtProtoHandle_ChallengeRep(char *pBuffer, int iLen);		// 第2步,认证服务器认证请求的响应处理
	int DrcomDialExtProtoSendLoginPacket();									// 第3步,发送认证数据
	int DrcomDialExtProtoHandle_LoginRes(char *pBuffer, int iLen);			// 第4步,接收认证结果处理
	int OnDrcomDialExtProtoLoginResualt();
	int DrcomDialCheckStaticIPAddress();

	int DrcomAuthSendClientPing();											// 发送心跳?
	int DrcomDialExtProtoHandle_ping(char* pBuffer, int len);				// 心跳?
	int DrcomAuthSendChallenge();											// 增加发送挑战值到2166，心跳1

	// ####################################################################
	// 防代理函数
	int SendNextDownloadModuleFileCmd();
	int SendNextDownloadModuleFileCmd(int nNowAntiProxyModuleUpdateStatus); 						// 发送防代理心跳
	unsigned long MadeCmdPacketCRCSum(unsigned char* ptrData, int nDataLen);
	void HandleClientRecvPacket(char* RecvData, int nRecvLen);										// 接收防代理心跳处理
	int IsDrcomAntiProxyModulePacket(int nUdpRecvLen, DR2133REQINFO* ptrRecvReqInfo);
	void HandleClientRecvPacket_code1eq2(int nUdpRecvLen, DR2133REQINFO* ptrRecvReqInfo);
	int IsModuleUpdateFirstPacket(DR2133REQINFO* ptrRecvReqInfo, \
			int nUdpRecvLen, \
			ANTIPROXYMODULECHECKSUMHEAD* ptrModuleCheckSumHeader\
			);

	void SetFirstTimeAnti(bool bFlag);
	bool GetIsFirstTimeAnti();
	int CheckIsModulePacketHeader8(ANTIPROXYDLLGETVERINFORET* lpClientInParam);
	int CheckIsModulePacketHeader5(ANTIPROXYDLLGETVERINFORET* lpClientInParam);
	// ####################################################################

	int SendAuthCmd(char* cmd, int iLen);
	int RecvAuthData(char* pBuffer, unsigned int iLen);
protected:
	bool GetCrcCheckField(unsigned char* pChallenge, \
			unsigned int nChallengeSize,\
			unsigned int type, unsigned long* pCrcBuff, \
			unsigned int* pnEncryptionType\
			);
	unsigned long DrcomCRC32(unsigned int nInitValue, unsigned char* ptrData, int nByteDataLen);
	unsigned int GetDrcomCRC(unsigned int org_crc);
	int is_dhcp_169_ip_addr(unsigned int ip_addr);

	// 修改默认路由
	bool ModifyRoute();
	bool ResetRoute();

private:
	bool m_bIsRunning;					// 认证线程是否正在运行
	bool m_bIsServiceRunning;			// 插件服务是否正在运行

	string m_sServerAddress;			// PPPoE服务器Ip
	int m_iServerPort;					// PPPoE服务器端口
	int m_iLocalPort;					// 绑定本地接收端口
	string m_iLocalAddress;				// 绑定本地接收发送地址
	DrUdpSocket m_UdpSocket;			// 接收服务器返回的socket对象
	DrPPPoEPluginSetp m_SetpCurrent;	// 当前认证步骤

	DrThread *m_pAuthDrThread;			// 认证线程
	DrCond *m_pDrSendCond;				// 同步认证线程信号量

	// 认证状态需要的参数
	int m_iChallengeID;
	unsigned char m_sChallengeSeed[SEED_LEN];
	char m_cEncryptionMode;
	bool m_bIsFirstTimeConnect;
	unsigned long m_ulDrcomDialExtProtoAuthLastCRC;
	unsigned int m_iDrcomDialExtProtoActiveCRC;
	unsigned int m_iIsDrcomDialConnectionFirstActive;
	unsigned char m_sDRCOM_CLIENT_KERNEL_VER;
	unsigned int m_uiAntiProxyResault;
	unsigned int m_AuthHostIP;

	struct _tagDrcomDogData m_AuthDogData;
	unsigned char m_KeepAliveMD5[MD5_LEN];
	unsigned int m_InternetAccessControl;
	unsigned int m_LocalNetAuthMode;
	int m_nClientPingNotResponseNum;
	string m_ClientPPPoEId;

	// 防代理标识
	unsigned int m_RandomIndex;
	unsigned char m_DownLoadReqPacketIndex;
	unsigned int m_nStartUpdateCount;
	unsigned int m_nModuleOnlineCount;
	int m_NextUpdateModuleCmdWaitTime; //sec
	int m_CHECK_MODULE_UPDATE_INTERVAL;
	unsigned short m_PACKET_CRC_CONST;
	unsigned char m_TMPcode1recExtchalleng[8];
	int m_CHECK_SVR_LINUX_MODULE_VER;
	int m_AntiProxyModuleUpdateStatus;
	unsigned int m_nServerRequireSendDrcomPingInterval;
	PANTIPROXYMODULECHECKSUMHEAD m_ptrServerDllPacketHead;
	int m_bHasNewVersionCheckMark;
	DrcomAntiModuleDownloadBuff m_DownloadModuleBuff;
	char m_AntiProxyModuleAuthDataBuff[MAX_AUTH_DATA_LEN];

	DrMutex *m_pIsFirstTimeAntiMutex;
	bool m_bIsFirstTimeAnti;

	_tagDrcomDialExtProtoNetWorkInfo m_DrcomDialExtProtoNetInfo[MAX_DRCOM_DIAL_EXT_PROTO_NET_NUM];
};

#endif /* DRPPOEPLUGIN_H_ */
