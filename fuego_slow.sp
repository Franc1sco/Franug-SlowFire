#include <sourcemod>
#include <sdkhooks>
#include <zombiereloaded>
#include <zr_tools>

new Handle:Timers[MAXPLAYERS + 1] = INVALID_HANDLE;


new Float:fireMovementSpeed = 0.6;

public Plugin:myinfo = 
{
	name = "SM Slow fire",
	author = "Franc1sco steam: franug",
	description = "Slow fire",
	version = "2.0",
	url = "http://www.zeuszombie.com/"
};

public OnPluginStart()
{
	CreateConVar("sm_SlowFire", "2.0", "Version", FCVAR_NOTIFY | FCVAR_DONTRECORD | FCVAR_CHEAT);
	
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(damagetype & DMG_BURN && IsPlayerAlive(client) && ZR_IsClientZombie(client))
	{
		if (Timers[client] == INVALID_HANDLE)
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fireMovementSpeed);
			Timers[client] = CreateTimer(0.3, Stop, client);
		}
		else
		{
			KillTimer(Timers[client]);
			Timers[client] = INVALID_HANDLE;
		
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fireMovementSpeed);
			Timers[client] = CreateTimer(0.3, Stop, client);
		}
	}
}

public Action:Stop(Handle:timer, any:client)
{
	Timers[client] = INVALID_HANDLE;
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		float velocidad = ZRT_GetClientAttributeValueFloat(client, "speed", 300.0);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", velocidad/300.0);
	}
}

public OnClientDisconnect(client)
{
	if (Timers[client] != INVALID_HANDLE)
    {
		KillTimer(Timers[client]);
		Timers[client] = INVALID_HANDLE;
	}
}