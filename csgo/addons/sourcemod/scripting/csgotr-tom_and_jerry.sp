#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <multicolors>
#include <csgoturkiye>
#include <emitsoundany>
#include <overlays>
#include <warden>

#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Tom and Jerry", 
	author = "oppa", 
	description = "Tom and Jerry game for jailbreak maps.", 
	version = "1.0", 
	url = "csgo-turkiye.com"
};

ConVar cv_tom_health_rate = null, cv_tom_speed = null, cv_milk_prize_health = null, cv_jerry_health = null, cv_jerry_speed = null, cv_cheese_prize_health = null, cv_tomandjerry_flags = null, cv_tom_weapon = null, cv_jerry_weapon = null;
bool b_game_status = false;
char s_tomandjerry_flags[32], s_tom_weapon[32], s_jerry_weapon[32];
int i_tom_health_rate, i_milk_prize_health, i_jerry_health, i_cheese_prize_health;
float f_tom_speed, f_jerry_speed, f_tom_pos[3] = {0.0, ...}, f_jerry_pos[3] = {0.0, ...}, f_random_pos[3] = {0.0, ...} ;
Handle h_player_model = INVALID_HANDLE;

public void OnPluginStart()
{   
    LoadTranslations("csgotr-tom_and_jerry.phrases.txt");
    CVAR_Load();
    RegConsoleCmd("sm_tomandjerry", TomAndJerry,  "Tom and Jerry Game");
    h_player_model = RegClientCookie("csgotr_tom_and_jerry_player_model", "Tom and Jerry Game Old Player Model Cookie", CookieAccess_Protected);
    HookEvent("round_start", Event_RoundEndStart);
    HookEvent("round_end", Event_RoundEndStart);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_death", Event_PlayerDeath);
}

public void OnMapStart()
{
    char s_map_name[ 32 ];
    GetCurrentMap(s_map_name, sizeof(s_map_name));
    if (strncmp(s_map_name, "workshop/", 9, false) == 0)
    {
        if (StrContains(s_map_name, "/jb_", false) == -1 && StrContains(s_map_name, "/jail_", false) == -1 && StrContains(s_map_name, "/ba_jail", false) == -1)PluginUnload();
    }
    else if (strncmp(s_map_name, "jb_", 3, false) != 0 && strncmp(s_map_name, "jail_", 5, false) != 0 && strncmp(s_map_name, "ba_jail", 3, false) != 0)PluginUnload();  
    CVAR_Load();
    Download();
    
}

void PluginUnload(){
    char s_plugin_name[ 256 ];
    GetPluginFilename(INVALID_HANDLE, s_plugin_name, sizeof(s_plugin_name));
    ServerCommand("sm plugins unload %s", s_plugin_name);
}

public Action Deneme(int client,int arrg){
    GetClientAbsOrigin(client, f_random_pos);
    f_random_pos[2] += 30.0;
    f_random_pos[1] += 60.0;
    f_random_pos[0] += 60.0;
    if (!TR_PointOutsideWorld(f_random_pos)){
    int i_entity = CreateEntityByName("prop_dynamic");
    if (IsValidEntity(i_entity))
    {
        SetEntityModel(i_entity, (GetRandomInt(0,1) == 0) ? "models/csgo-turkiye_com/plugin/tomandjerry/cheese.mdl" : "models/csgo-turkiye_com/plugin/tomandjerry/milk.mdl");
        SetEntProp(i_entity, Prop_Send, "m_usSolidFlags", 8);
        SetEntProp(i_entity, Prop_Send, "m_CollisionGroup", 1);
        SetEntPropFloat(i_entity, Prop_Send, "m_flModelScale", 0.80);
        SDKHook(i_entity, SDKHook_StartTouch, Hook_StartTouch);
        DispatchKeyValue(i_entity, "targetname", "csgo-turkiye_com-tomandjerry");
        ActivateEntity(i_entity);
        DispatchSpawn(i_entity);
        TeleportEntity(i_entity, f_random_pos, NULL_VECTOR, NULL_VECTOR);
        }
    }
}

void Download(){
    AddFileToDownloadsTable("models/player/custom_player/pakcan/tom/tom.dx90.vtx");
    AddFileToDownloadsTable("models/player/custom_player/pakcan/tom/tom.mdl");
    AddFileToDownloadsTable("models/player/custom_player/pakcan/tom/tom.phy");
    AddFileToDownloadsTable("models/player/custom_player/pakcan/tom/tom.vvd");
    AddFileToDownloadsTable("materials/models/player/pakcan/tom/tom.vmt");
    AddFileToDownloadsTable("materials/models/player/pakcan/tom/tom.vtf");
    PrecacheModel("models/player/custom_player/pakcan/tom/tom.mdl");
    
    AddFileToDownloadsTable("models/player/custom_player/mertexe/jerry/jerry.dx90.vtx");
    AddFileToDownloadsTable("models/player/custom_player/mertexe/jerry/jerry.mdl");
    AddFileToDownloadsTable("models/player/custom_player/mertexe/jerry/jerry.phy");
    AddFileToDownloadsTable("models/player/custom_player/mertexe/jerry/jerry.vvd");
    AddFileToDownloadsTable("materials/models/player/custom/mertexe/jerry/jerry.vmt");
    AddFileToDownloadsTable("materials/models/player/custom/mertexe/jerry/jerry.vtf");
    PrecacheModel("models/player/custom_player/mertexe/jerry/jerry.mdl");

    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/tomandjerry/milk.dx90.vtx");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/tomandjerry/milk.mdl");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/tomandjerry/milk.phy");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/tomandjerry/milk.vvd");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/tomandjerry/milk.vmt");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/tomandjerry/milk.vtf");
    PrecacheModel("models/csgo-turkiye_com/plugin/tomandjerry/milk.mdl");

    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/tomandjerry/cheese.dx90.vtx");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/tomandjerry/cheese.mdl");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/tomandjerry/cheese.phy");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/tomandjerry/cheese.vvd");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/tomandjerry/cheese.vmt");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/tomandjerry/cheese.vtf");
    PrecacheModel("models/csgo-turkiye_com/plugin/tomandjerry/cheese.mdl");
    
    AddFileToDownloadsTable("sound/csgo-turkiye_com/tomandjerry/game.mp3");
    PrecacheSoundAny("csgo-turkiye_com/tomandjerry/game.mp3", false);
    
    AddFileToDownloadsTable("sound/csgo-turkiye_com/tomandjerry/start.mp3");
    PrecacheSoundAny("csgo-turkiye_com/tomandjerry/start.mp3", false);

    AddFileToDownloadsTable("sound/csgo-turkiye_com/tomandjerry/end.mp3");
    PrecacheSoundAny("csgo-turkiye_com/tomandjerry/end.mp3", false);

    PrecacheDecalAnyDownload("models/csgo-turkiye_com/plugin/tomandjerry/start");
}

void CVAR_Load(){
    PluginSetting();
    cv_tom_health_rate = CreateConVar("sm_tomandjerry-tom_health_rate", "50", "Jerry başına verilecek can miktarı. Tom sayısına bölünecektir.");
    cv_tom_speed = CreateConVar("sm_tomandjerry-tom_speed", "1.0", "Tom'un alacağı hız miktarı.");
    cv_milk_prize_health = CreateConVar("sm_tomandjerry-milk_prize_health", "30", "Süt ödülünde Tom'un alacağı can miktarı");
    cv_jerry_health = CreateConVar("sm_tomandjerry-jerry_health", "25", "Jerry'nin oyun başlangıcında alacağı can mikatarı.");
    cv_jerry_speed = CreateConVar("sm_tomandjerry-jerry_speed", "1.5", "Jerry'nin aşcağı hız miktarı.");
    cv_cheese_prize_health = CreateConVar("sm_tomandjerry-cheese_prize_health", "15", "Peynir ödülünde Jerry'nin alacağı can miktarı.");
    cv_tomandjerry_flags = CreateConVar("sm_tomandjerry-flags", "", "Komutçu ve Root hariç kullanacak yetkililerin harfleri. Virgül (,) ile ayırınız.");
    cv_tom_weapon = CreateConVar("sm_tomandjerry-tom_weapon", "weapon_knife", "Tom başlangıç silahı.");
    cv_jerry_weapon = CreateConVar("sm_tomandjerry-jerry_weapon", "weapon_knife", "Jerry başlangıç silahı.");
    AutoExecConfig(true, "tom_and_jerry","CSGO_Turkiye");
    i_tom_health_rate = GetConVarInt(cv_tom_health_rate);
    f_tom_speed = GetConVarFloat(cv_tom_speed);
    i_milk_prize_health = GetConVarInt(cv_milk_prize_health);
    i_jerry_health = GetConVarInt(cv_milk_prize_health);
    f_jerry_speed = GetConVarFloat(cv_jerry_speed);
    i_cheese_prize_health = GetConVarInt(cv_cheese_prize_health);
    GetConVarString(cv_tomandjerry_flags, s_tomandjerry_flags, sizeof(s_tomandjerry_flags));
    GetConVarString(cv_tom_weapon, s_tom_weapon, sizeof(s_tom_weapon));
    GetConVarString(cv_jerry_weapon, s_jerry_weapon, sizeof(s_jerry_weapon));
    HookConVarChange(cv_tom_health_rate, OnCvarChanged);
    HookConVarChange(cv_tom_speed, OnCvarChanged);
    HookConVarChange(cv_milk_prize_health, OnCvarChanged);
    HookConVarChange(cv_jerry_health, OnCvarChanged);
    HookConVarChange(cv_jerry_speed, OnCvarChanged);
    HookConVarChange(cv_cheese_prize_health, OnCvarChanged);
    HookConVarChange(cv_tomandjerry_flags, OnCvarChanged);
    HookConVarChange(cv_tom_weapon, OnCvarChanged);
    HookConVarChange(cv_jerry_weapon, OnCvarChanged);
}

public int OnCvarChanged(Handle convar, const char[] oldVal, const char[] newVal)
{
    if(convar == cv_tom_health_rate) i_tom_health_rate = StringToInt(newVal);
    else if(convar == cv_tom_speed) f_tom_speed = StringToFloat(newVal);
    else if(convar == cv_milk_prize_health) i_milk_prize_health = StringToInt(newVal);
    else if(convar == cv_jerry_health) i_jerry_health = StringToInt(newVal);
    else if(convar == cv_jerry_speed) f_jerry_speed = StringToFloat(newVal);
    else if(convar == cv_cheese_prize_health) i_cheese_prize_health = StringToInt(newVal);
    else if(convar == cv_tomandjerry_flags) strcopy(s_tomandjerry_flags, sizeof(s_tomandjerry_flags), newVal);
    else if(convar == cv_tom_weapon) strcopy(s_tom_weapon, sizeof(s_tom_weapon), newVal);
    else if(convar == cv_jerry_weapon) strcopy(s_jerry_weapon, sizeof(s_jerry_weapon), newVal);
}

public Action TomAndJerry(int client,int args)
{
    if(client!=0){
        if(IsValidClient(client) && (warden_iswarden(client) || CheckAdminFlag(client, s_tomandjerry_flags)) ){
            TomAndJerry_Menu().Display(client, MENU_TIME_FOREVER);
        }
    }else PrintToServer("%s %t", s_tag, "Console Message");
}

Menu TomAndJerry_Menu()
{
    char s_temp[ 256 ];
    Menu menu = new Menu(MenuCallback);
    menu.SetTitle("%s %t", s_tag, "Menu Title");
    if(b_game_status){
        Format(s_temp, sizeof(s_temp), "%t", "Stop");
        menu.AddItem("stop", s_temp);
    }else{
        Format(s_temp, sizeof(s_temp), "%t", "Start");
        menu.AddItem("start", s_temp, ((f_tom_pos[0]!=0.0 || f_tom_pos[1]!=0.0 || f_tom_pos[2]!=0.0) && (f_jerry_pos[0]!=0.0 || f_jerry_pos[1]!=0.0 || f_jerry_pos[2]!=0.0)) ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        Format(s_temp, sizeof(s_temp), "%t", "Tom Position");
        menu.AddItem("tom", s_temp);
        Format(s_temp, sizeof(s_temp), "%t", "Jerry Position");
        menu.AddItem("jerry", s_temp);
    }
    return menu;
}

int MenuCallback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if(IsValidClient(client) && (warden_iswarden(client) || CheckAdminFlag(client, s_tomandjerry_flags)) ){
            char option[32];
            menu.GetItem(param2, option, sizeof(option));
            if (StrEqual(option, "stop", true))
            {
                if(b_game_status)GameStop();
                else CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Game Inactive");
            }else if(StrEqual(option, "start", true)){
                if(b_game_status)CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Game Active");
                else{
                    if((f_tom_pos[0]!=0.0 || f_tom_pos[1]!=0.0 || f_tom_pos[2]!=0.0) && (f_jerry_pos[0]!=0.0 || f_jerry_pos[1]!=0.0 || f_jerry_pos[2]!=0.0)){
                        if(GetAliveTeamCount(2)>=2 && GetAliveTeamCount(3)>=1){
                            b_game_status = true;
                            CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "Game Start Info", client);
                            EmitSoundToAllAny("csgo-turkiye_com/tomandjerry/start.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
                            ShowOverlayAll("models/csgo-turkiye_com/plugin/tomandjerry/start", 5.0);
                            DeleteTomAndJerryItemsAndWeapons();
                            char s_message[ 512 ];
                            Format(s_message, sizeof(s_message),"%t", "Game Start Message Jerry");
                            SendPanelToTeam(s_message, 2);
                            Format(s_message, sizeof(s_message),"%t", "Game Start Message Tom");
                            SendPanelToTeam(s_message, 3);
                            for(int i = 1; i <= MaxClients; i++)PlayerStartClient(i);
                            CreateTimer(5.0, GameStart);
                        }else CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Team Count Error");
                    }else CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Position Error");
                }
            }else if(StrEqual(option, "tom", true)){
                if(b_game_status)CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Game Active");
                else{
                    GetAimCoords(client, f_tom_pos);
                    f_tom_pos[2]+=5.0;
                    if (TR_PointOutsideWorld(f_tom_pos)){
                        CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "TR_PointOutsideWorld Error");
                        f_tom_pos[0] = 0.0;
                        f_tom_pos[1] = 0.0;
                        f_tom_pos[2] = 0.0;
                    }else  CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Tom Success");
                } 
            }else if(StrEqual(option, "jerry", true)){
                if(b_game_status)CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Game Active");
                else{
                    GetAimCoords(client, f_jerry_pos);
                    f_jerry_pos[2]+=5.0;
                    if (TR_PointOutsideWorld(f_jerry_pos)){
                        CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "TR_PointOutsideWorld");
                        f_jerry_pos[0] = 0.0;
                        f_jerry_pos[1] = 0.0;
                        f_jerry_pos[2] = 0.0;
                    }else  CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Jerry Success");
                }
            }
            TomAndJerry_Menu().Display(client, MENU_TIME_FOREVER);
        }       
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

public Action GameStart(Handle timer)
{
    if(b_game_status){
        for(int i = 1; i <= MaxClients; i++)
            if (IsValidClient(i) && IsPlayerAlive(i)){
                if(GetClientTeam(i)==2)SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", f_jerry_speed);
                else if(GetClientTeam(i)==3)SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", f_tom_speed);
            }
        CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "Game Start");
        EmitSoundToAllAny("csgo-turkiye_com/tomandjerry/game.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
        Prize();
    }
}

void Prize(){
    if(b_game_status){
        int i_random_player = RandomPlayer();
        if(i_random_player > 0){
            GetClientAbsOrigin(i_random_player, f_random_pos);
            CreateTimer(GetRandomFloat(5.0 , 15.0), PrizeAdd);
        }else Prize();
    }
}

public Action PrizeAdd(Handle timer)
{
    if(b_game_status){
        f_random_pos[2] += 30.0;
        if (!TR_PointOutsideWorld(f_random_pos)){
            int i_entity = CreateEntityByName("prop_dynamic");
            if (IsValidEntity(i_entity))
            {
                SetEntityModel(i_entity, (GetRandomInt(0,1) == 0) ? "models/csgo-turkiye_com/plugin/tomandjerry/cheese.mdl" : "models/csgo-turkiye_com/plugin/tomandjerry/milk.mdl");
                SetEntProp(i_entity, Prop_Send, "m_usSolidFlags", 8);
                SetEntProp(i_entity, Prop_Send, "m_CollisionGroup", 1);
                SetEntPropFloat(i_entity, Prop_Send, "m_flModelScale", 0.80);
                SDKHook(i_entity, SDKHook_StartTouch, Hook_StartTouch);
                DispatchKeyValue(i_entity, "targetname", "csgo-turkiye_com-tomandjerry");
                ActivateEntity(i_entity);
                DispatchSpawn(i_entity);
                TeleportEntity(i_entity, f_random_pos, NULL_VECTOR, NULL_VECTOR);
            }
        }
        Prize();
    }
}

public Hook_StartTouch(int entity, int client)
{
    if(b_game_status){
        if (IsValidClient(client)) 
        {
            if(IsValidEntity(entity)){
                char s_class_name[64], s_model_name[256], s_target_name[64];
                GetEdictClassname(entity, s_class_name, sizeof(s_class_name));
                GetEntPropString(entity, Prop_Data, "m_ModelName", s_model_name, sizeof(s_model_name));
                GetEntPropString(entity, Prop_Data, "m_iName", s_target_name, sizeof(s_target_name));
                if (StrEqual(s_class_name, "prop_dynamic")  && StrEqual(s_target_name, "csgo-turkiye_com-tomandjerry") && (StrEqual(s_model_name, "models/csgo-turkiye_com/plugin/tomandjerry/cheese.mdl") && GetClientTeam(client) == 2) || (StrEqual(s_model_name, "models/csgo-turkiye_com/plugin/tomandjerry/milk.mdl") && GetClientTeam(client) == 3) && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == -1)
                {
                    SDKUnhook(entity, SDKHook_StartTouch, Hook_StartTouch);
                    RemoveEntity(entity);
                    if(GetRandomInt(0, 10) > 7){
                        char s_weapon[32], s_weapons[5][] = {"weapon_knife","weapon_hammer","weapon_axe","weapon_spanner","weapon_taser"};
                        int i_weapon = GetRandomInt(0,4);
                        Format(s_weapon, sizeof(s_weapon), "%s", GetClientTeam(client)==2 ? s_jerry_weapon : s_tom_weapon);
                        Format(s_weapon, sizeof(s_weapon), "%s", StrEqual(s_weapon, s_weapons[i_weapon]) ? "weapon_healthshot" : s_weapons[i_weapon]);
                        GivePlayerItem(client, s_weapon);
                        CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "Player Prize Weapon", client, s_weapon, (GetClientTeam(client)==2) ? "Jerry" : "Tom");
                    }else{
                        int i_health = (GetClientTeam(client)==2) ? i_milk_prize_health : i_cheese_prize_health;
                        SetEntityHealth(client, GetClientHealth(client)+i_health);
                        CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "Player Prize Health", client, i_health, (GetClientTeam(client)==2) ? "Jerry" : "Tom");
                    }
                }
            }
        }
    }
}

int RandomPlayer()
{
	int[] i_clients = new int[MaxClients];
	int i_client_count;
	for (int i = 1; i <= MaxClients; i++)
		if (IsValidClient(i) && (GetClientTeam(i) == 2 || GetClientTeam(i) == 3) && IsPlayerAlive(i))
			i_clients[i_client_count++] = i;
	return (i_client_count == 0) ? -1 : i_clients[GetRandomInt(0, i_client_count - 1)];
} 

void GameStop(){
    if(b_game_status){
        b_game_status = false;
        f_tom_pos[0] = 0.0;
        f_tom_pos[1] = 0.0;
        f_tom_pos[2] = 0.0;
        f_jerry_pos[0] = 0.0;
        f_jerry_pos[1] = 0.0;
        f_jerry_pos[2] = 0.0;
        f_random_pos[0] = 0.0;
        f_random_pos[1] = 0.0;
        f_random_pos[2] = 0.0;
        DeleteTomAndJerryItemsAndWeapons();
        for(int i = 1; i <= MaxClients; i++)
            if(IsValidClient(i)){
                SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
                SetEntityHealth(i, 100);
                char s_player_model[PLATFORM_MAX_PATH];
                GetClientCookie(i, h_player_model, s_player_model, sizeof(s_player_model));
                if (!StrEqual(s_player_model, "", true))SetEntityModel(i, s_player_model);
                if(IsPlayerAlive(i)){
                    DeleteWeaponClient(i);
                    GivePlayerItem(i, "weapon_knife");
                }
            }
        EmitSoundToAllAny("csgo-turkiye_com/tomandjerry/end.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
    }  
}

void SendPanelToTeam(char [] message, int team)
{
	Panel GamePanel = new Panel();
	GamePanel.DrawText(message);
	for(int i = 1; i <= MaxClients; i++)if(IsValidClient(i) && GetClientTeam(i) == team)GamePanel.Send(i, Handler_DoNothing, 5);
	delete GamePanel;
}

int Handler_DoNothing(Menu menu, MenuAction action, int param1, int param2)
{
	//CS-GO Turkiye | csgo-turkiye.com
}

void PlayerStartClient(int client){
    if(IsValidClient(client) && IsPlayerAlive(client) && (GetClientTeam(client)==2 || GetClientTeam(client)==3)){
        char s_player_model[PLATFORM_MAX_PATH];
        GetClientModel(client, s_player_model, sizeof(s_player_model));
        SetClientCookie(client, h_player_model, s_player_model);
        DeleteWeaponClient(client);
        SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
        if(GetClientTeam(client)==2){
            GivePlayerItem(client, s_jerry_weapon);
            SetEntityHealth(client, i_jerry_health);
            SetEntityModel(client, "models/player/custom_player/mertexe/jerry/jerry.mdl");
            TeleportEntity(client, f_jerry_pos, NULL_VECTOR, NULL_VECTOR);
        }else if(GetClientTeam(client)==3){
            GivePlayerItem(client, s_tom_weapon);
            SetEntityHealth(client, RoundFloat(float((GetAliveTeamCount(2)*i_tom_health_rate)/GetAliveTeamCount(3))));
            SetEntityModel(client, "models/player/custom_player/pakcan/tom/tom.mdl");
            TeleportEntity(client, f_tom_pos, NULL_VECTOR, NULL_VECTOR);
        }
    }
}

void DeleteWeaponClient(int client){
	int j;
	while (j < 5)
	{
		int weapon = GetPlayerWeaponSlot(client, j);
		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);
		}
		j++;
	}
}

void DeleteTomAndJerryItemsAndWeapons(){
	char s_target_name[64],s_class_name[64];
	for (int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
            GetEntPropString(i, Prop_Data, "m_iName", s_target_name, sizeof(s_target_name));
            GetEdictClassname(i, s_class_name, sizeof(s_class_name));
            if (StrContains(s_target_name, "csgo-turkiye_com-tomandjerry")==0 || ((StrContains(s_class_name, "weapon_") != -1 || StrContains(s_class_name, "item_") != -1) && GetEntDataEnt2(i, FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity")) == -1)){
                if(StrContains(s_target_name, "csgo-turkiye_com-tomandjerry")==0 )SDKUnhook(i, SDKHook_StartTouch, Hook_StartTouch);
                RemoveEntity(i);
            }
		}
	}
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
    if(b_game_status){
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsValidClient(client) && IsPlayerAlive(client)){
            ForcePlayerSuicide(client);
            CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Player Spawn Error");
        }
    }
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    if(b_game_status){
        int i_jerry_alive_count = GetAliveTeamCount(2);
        int client = GetClientOfUserId(event.GetInt("userid"));
        if(IsValidClient(client)){
            if(GetClientTeam(client)==2){
                CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "Jerry is Dead", client, i_jerry_alive_count);
                if(i_jerry_alive_count < 2){
                    int i_winner = OnePlayerWinner();
                    if(i_winner != -1)CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "Winner", i_winner);
                    else CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "No Winner Found");
                    GameStop();
                }
            }else if(GetClientTeam(client)==3){
                int attacker = GetClientOfUserId(event.GetInt("attacker"));
                if(IsValidClient(attacker)  && GetClientTeam(attacker)==2 && IsPlayerAlive(attacker))CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "Winner 2",client, attacker);
                else CPrintToChatAll("%s%s %t", s_tag_color, s_tag, "No Winner Found 2", client);
                GameStop();
            }
        }
    }
}

int OnePlayerWinner(){
    for (new i=1; i<=MaxClients; i++)if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)return i;
    return -1;
}

void Event_RoundEndStart(Event event, const char[] name, bool dontBroadcast) 
{
    if(b_game_status)GameStop();
}