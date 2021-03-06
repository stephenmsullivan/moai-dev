//----------------------------------------------------------------//
// Copyright (c) 2010-2011 Zipline Games, Inc. 
// All Rights Reserved. 
// http://getmoai.com
//----------------------------------------------------------------//

#import <moaiext-iphone/MOAISmartFoxIOS.h>
#import <moaiext-iphone/NSDictionary+MOAILib.h>
#import <moaiext-iphone/NSString+MOAILib.h>

//================================================================//
// lua
//================================================================//
int MOAISmartFoxIOS::_init( lua_State* L )
{
	MOAILuaState state ( L );    
    bool   debug                = state.GetValue < bool >( 1, true );
    NSString* configFilePath       = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 2, "config.xml" ) ];
    bool   connectOnSuccess     = state.GetValue < bool >( 3, true );
    
 	/**
     * Create a connection to SmartFoxServer as soon as the application has launched.
     * First, allocate a SmartFox2XClient instance
     */
	MOAISmartFoxIOS::Get ().mSmartFox = [[SmartFox2XClient alloc] initSmartFoxWithDebugMode:debug delegate:MOAISmartFoxIOS::Get ().mSmartFoxDelgate];
	
    /*
     * Load our XML config file and once done, attempt a connection
     */
	[MOAISmartFoxIOS::Get ().mSmartFox loadConfig:configFilePath connectOnSuccess:connectOnSuccess];
    
}

int MOAISmartFoxIOS::_initWithSocket( lua_State* L )
{
	MOAILuaState state ( L );	
    bool   debug    = state.GetValue < bool >( 1, true );
    NSString* ip    = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 2, "dev.playnomi.net" ) ];
    int   port      = state.GetValue < int >( 3, 9933 );
    
 	/**
     * Create a connection to SmartFoxServer as soon as the application has launched.
     * First, allocate a SmartFox2XClient instance
     */
	MOAISmartFoxIOS::Get ().mSmartFox = [[SmartFox2XClient alloc] initSmartFoxWithDebugMode:debug delegate:MOAISmartFoxIOS::Get ().mSmartFoxDelgate];
	
    /*
     * Load our XML config file and once done, attempt a connection
     */    
	[MOAISmartFoxIOS::Get ().mSmartFox connect:ip port:port ];
    
}

int MOAISmartFoxIOS::_connect( lua_State* L )
{
	MOAILuaState state ( L );	
    NSString* ip    = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "dev.playnomi.net" ) ];
    int   port      = state.GetValue < int >( 2, 9933 );
    
	[MOAISmartFoxIOS::Get ().mSmartFox connect:ip port:port ];
}

int MOAISmartFoxIOS::_isConnected( lua_State* L)
{
	MOAILuaState state ( L );
	
	BOOL result = false;
	
	if (MOAISmartFoxIOS::Get().mSmartFox) {
	
		result = MOAISmartFoxIOS::Get().mSmartFox.isConnected;
		
	}
		
	lua_pushboolean ( state, result );
	
	return 1;
}

int MOAISmartFoxIOS::_sendJoinRoomRequest( lua_State* L )
{
    MOAILuaState state ( L );
	
	NSString* roomId       = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
    bool   asSpectator     = state.GetValue < bool >( 2, false );
    
    // this makes sure you don't leave the prior room
    NSNumber* roomIdToLeave   = [NSNumber numberWithInt:-1];
	
    
    NSLog(@"join room as spectator? %@ %i", roomId, asSpectator);
    
	[MOAISmartFoxIOS::Get ().mSmartFox send:[JoinRoomRequest requestWithId:roomId pass:nil roomIdToLeave:roomIdToLeave asSpect:asSpectator]];
}


int MOAISmartFoxIOS::_login( lua_State* L )
{
    MOAILuaState state ( L );
	
	NSString* loginName = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	NSString* password	= [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 2, "" ) ];
	NSString* zone		= [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
	NSString* gameType  = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 4, nil ) ];
	
	SFSObject* obj		= [SFSObject newInstance];	

	if (gameType != nil) {

		NSLog(@"login with app_id %@", gameType);
		
		[obj putUtfString:@"app_id" value:gameType];
	}
	else{
		obj = nil;
	}
	
	[MOAISmartFoxIOS::Get ().mSmartFox send:[LoginRequest requestWithUserName:loginName password:password zoneName:zone params:obj]];

}

int MOAISmartFoxIOS::_sendLogoutRequest( lua_State* L )
{
	[MOAISmartFoxIOS::Get ().mSmartFox send:[LogoutRequest request]];
}

int MOAISmartFoxIOS::_sendPublicMessageRequest( lua_State* L )
{
    MOAILuaState state ( L );
    
    NSString* message = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	//NSString* room = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 2, "" ) ];
    
    [MOAISmartFoxIOS::Get ().mSmartFox send:[PublicMessageRequest requestWithMessage:message params:nil targetRoom:nil]];
 }

int MOAISmartFoxIOS::_sendLeaveRoomRequest( lua_State* L )
{
    MOAILuaState state ( L );
    
    //NSString* roomId = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	//NSString* room = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 2, "" ) ];
	
	// removes user from current room by default
    [MOAISmartFoxIOS::Get ().mSmartFox send:[LeaveRoomRequest requestWithRoom:nil]];
}


int MOAISmartFoxIOS::_sendRoomVariablesRequest(lua_State* L ) {

	MOAILuaState state ( L );

	NSString* message = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];

	NSArray * roomVariables = nil;
	
        
	[MOAISmartFoxIOS::Get ().mSmartFox send:[SetRoomVariablesRequest requestWithRoomVariables:roomVariables room:nil]];

}

int MOAISmartFoxIOS::_sendQuickJoinGameRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSString* varName = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	int matchOperator = state.GetValue < int >( 2, 0 );	

	MatchExpression *exp = nil;
	
	if (matchOperator == BOOL_MATCH_EQUALS) {
		
		Boolean value = state.GetValue < Boolean >( 3, false );
		exp = [MatchExpression expressionWithVarName:varName condition:[BoolMatch boolMatchEquals] value:[NSNumber numberWithBool:value]];
	}
	else if (matchOperator == BOOL_MATCH_NOT_EQUALS) {

		Boolean value = state.GetValue < Boolean >( 3, false );
		exp = [MatchExpression expressionWithVarName:varName condition:[BoolMatch boolMatchEquals] value:[NSNumber numberWithBool:value]];
		
	}
	else if (matchOperator == NUMBER_MATCH_EQUALS){
		
		int value = state.GetValue < int >( 3, 0 );
		
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchEquals] value:[NSNumber numberWithInt:value]];
		
	}
	else if (matchOperator == NUMBER_MATCH_NOT_EQUALS){

			int value = state.GetValue < int >( 3, 0 );
			exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchNotEquals] value:[NSNumber numberWithInt:value]];
	}
	else if (matchOperator == NUMBER_MATCH_GREATER_THAN){

		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchGreaterThan] value:[NSNumber numberWithInt:value]];
	}
	else if (matchOperator == NUMBER_MATCH_GREATER_THAN_OR_EQUAL_TO){
		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchGreaterThanOrEqualTo] value:[NSNumber numberWithInt:value]];
	}
	else if (matchOperator == NUMBER_MATCH_LESS_THAN){
		
		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchLessThan] value:[NSNumber numberWithInt:value]];
		
	}
	else if (matchOperator == NUMBER_MATCH_LESS_THAN_OR_EQUAL_TO){

		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchLessThanOrEqualTo] value:[NSNumber numberWithInt:value]];
		
	}
	else if (matchOperator == STRING_MATCH_EQUALS){

		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchEquals] value:value];
		
	}
	else if (matchOperator == STRING_MATCH_NOT_EQUALS){

		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchNotEquals] value:value];
		
	}
	else if (matchOperator == STRING_MATCH_CONTAINS){

		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchContains] value:value];
		
	}
	else if (matchOperator == STRING_MATCH_STARTS_WITH){

		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchStartsWith] value:value];
		
	}
	else if (matchOperator == STRING_MATCH_ENDS_WITH){

		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchEndsWith] value:value];
	}
	else {
		
		NSLog(@"invalid match type %i", matchOperator);
	}
	
	if (exp == nil)
	{
		// error here
		NSLog(@"no valid match expression %i", matchOperator);
		
	}
	
	// todo if we need more than one condition
    //  exp = [MatchExpression expressionWithVarName:@"min_bet" condition:[NumberMatch numberMatchEquals] value:@"5"];
	
	NSString* groupName			= [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 4, "" ) ];
	NSArray * roomGroupNames	= [[NSArray alloc] initWithObjects:groupName, nil];
	
	[MOAISmartFoxIOS::Get ().mSmartFox send:[QuickJoinGameRequest requestWithMatchExpression:exp whereToSearch:roomGroupNames roomToLeave:nil]];
}



int MOAISmartFoxIOS::_sendUserVariablesRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSString* message = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	//NSString* room = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 2, "" ) ];
	
	NSArray * userVariables = nil;
	
	[MOAISmartFoxIOS::Get ().mSmartFox send:[SetUserVariablesRequest requestWithUserVariables:userVariables room:nil]];	
}

int MOAISmartFoxIOS::_sendObjectMessageRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSString* cmd = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	NSString* message = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 2, "" ) ];

	SFSObject* obj = [SFSObject newInstance];
	
	[obj putUtfString:@"cmd" value:cmd];
	[obj putUtfString:@"message" value:message];
	
	[MOAISmartFoxIOS::Get ().mSmartFox send:[ObjectMessageRequest requestWithObject:obj targetRoom:nil recipients:nil]];	
}

int MOAISmartFoxIOS::_sendExtensionRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSString* cmd = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	NSString* message = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 2, "" ) ];
	SFSObject* obj = [SFSObject newInstance];

	[obj putUtfString:@"message" value:message];
	
	[MOAISmartFoxIOS::Get ().mSmartFox send:[ExtensionRequest requestWithExtCmd:cmd params:obj]];
}

int MOAISmartFoxIOS::_sendInitBuddyListRequest(lua_State* L ) {

	[MOAISmartFoxIOS::Get ().mSmartFox send:[InitBuddyListRequest request] ];
}

int MOAISmartFoxIOS::_sendAddBuddyRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSString* name = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	[MOAISmartFoxIOS::Get ().mSmartFox send:[AddBuddyRequest requestWithBuddyName:name] ];
	
}

int MOAISmartFoxIOS::_sendRemoveBuddyRequest(lua_State* L ) {

	MOAILuaState state ( L );
	
	NSString* name = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	[MOAISmartFoxIOS::Get ().mSmartFox send:[RemoveBuddyRequest requestWithBuddyName:name] ];	
}

int MOAISmartFoxIOS::_sendBlockBuddyRequest(lua_State* L ) {

	MOAILuaState state ( L );
	
	NSString* name = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	Boolean value  = state.GetValue < Boolean >( 2, false );
	
	[MOAISmartFoxIOS::Get ().mSmartFox send:[BlockBuddyRequest requestWithBuddyName:name blocked:value] ];
}

int MOAISmartFoxIOS::_sendGoOnlineRequest(lua_State* L ) {

	MOAILuaState state ( L );	
	
	Boolean value  = state.GetValue < Boolean >( 1, false );
	[MOAISmartFoxIOS::Get ().mSmartFox send:[GoOnlineRequest requestWithOnline:value] ];
}

int MOAISmartFoxIOS::_sendSetBuddyVariablesRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
	
	//todo: translate the room variables
	NSArray * roomVariables = nil;
	[MOAISmartFoxIOS::Get ().mSmartFox send:[SetBuddyVariablesRequest requestWithBuddyVariables:roomVariables] ];
}

int MOAISmartFoxIOS::_sendSpectatorToPlayerRequest(lua_State* L ) {

	MOAILuaState state ( L );
	
	NSString* cmd = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];	
	
	//todo: translate the room variables
	NSArray * roomVariables = nil;
	[MOAISmartFoxIOS::Get ().mSmartFox send:[SpectatorToPlayerRequest requestWithTargetRoom:nil] ];

}


int MOAISmartFoxIOS::_sendPlayerToSpectatorRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSString* cmd = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	
	//todo: translate the room variables
	NSArray * roomVariables = nil;
	[MOAISmartFoxIOS::Get ().mSmartFox send:[PlayerToSpectatorRequest requestWithTargetRoom:nil] ];
	
}

int MOAISmartFoxIOS::_sendFindRoomsRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
	
	NSString* varName = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	int matchOperator = state.GetValue < int >( 2, 0 );
	
	MatchExpression *exp = nil;
	
	if (matchOperator == BOOL_MATCH_EQUALS) {
		
		Boolean value = state.GetValue < Boolean >( 3, false );
		exp = [MatchExpression expressionWithVarName:varName condition:[BoolMatch boolMatchEquals] value:[NSNumber numberWithBool:value]];
	}
	else if (matchOperator == BOOL_MATCH_NOT_EQUALS) {
		
		Boolean value = state.GetValue < Boolean >( 3, false );
		exp = [MatchExpression expressionWithVarName:varName condition:[BoolMatch boolMatchEquals] value:[NSNumber numberWithBool:value]];
		
	}
	else if (matchOperator == NUMBER_MATCH_EQUALS){
		
		int value = state.GetValue < int >( 3, 0 );
		
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchEquals] value:[NSNumber numberWithInt:value]];
		
	}
	else if (matchOperator == NUMBER_MATCH_NOT_EQUALS){
		
		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchNotEquals] value:[NSNumber numberWithInt:value]];
	}
	else if (matchOperator == NUMBER_MATCH_GREATER_THAN){
		
		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchGreaterThan] value:[NSNumber numberWithInt:value]];
	}
	else if (matchOperator == NUMBER_MATCH_GREATER_THAN_OR_EQUAL_TO){
		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchGreaterThanOrEqualTo] value:[NSNumber numberWithInt:value]];
	}
	else if (matchOperator == NUMBER_MATCH_LESS_THAN){
		
		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchLessThan] value:[NSNumber numberWithInt:value]];
		
	}
	else if (matchOperator == NUMBER_MATCH_LESS_THAN_OR_EQUAL_TO){
		
		int value = state.GetValue < int >( 3, 0 );
		exp = [MatchExpression expressionWithVarName:varName condition:[NumberMatch numberMatchLessThanOrEqualTo] value:[NSNumber numberWithInt:value]];
		
	}
	else if (matchOperator == STRING_MATCH_EQUALS){
		
		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchEquals] value:value];
		
	}
	else if (matchOperator == STRING_MATCH_NOT_EQUALS){
		
		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchNotEquals] value:value];
		
	}
	else if (matchOperator == STRING_MATCH_CONTAINS){
		
		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchContains] value:value];
		
	}
	else if (matchOperator == STRING_MATCH_STARTS_WITH){
		
		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchStartsWith] value:value];
		
	}
	else if (matchOperator == STRING_MATCH_ENDS_WITH){
		
		NSString* value = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 3, "" ) ];
		exp = [MatchExpression expressionWithVarName:varName condition:[StringMatch stringMatchEndsWith] value:value];
	}
	else {
		
		NSLog(@"invalid match type %i", matchOperator);
	}
	
	if (exp == nil)
	{
		// error here
		NSLog(@"no valid match expression %i", matchOperator);
		
	}
	
	NSString* groupId = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 4, nil ) ];
	int limit		  = state.GetValue < int >( 5, 0 );
	
	//todo: translate the room variables
	NSArray * roomVariables = nil;
	[MOAISmartFoxIOS::Get ().mSmartFox send:[FindRoomsRequest requestWithExpr:exp groupId:groupId limit:limit] ];
	
}


int MOAISmartFoxIOS::_sendSubscribeRoomGroupRequest(lua_State* L ) {
	
	MOAILuaState state ( L );

	NSString* groupId = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, "" ) ];
	[MOAISmartFoxIOS::Get ().mSmartFox send:[SubscribeRoomGroupRequest requestWithGroupId:groupId] ];
    
}

int MOAISmartFoxIOS::_sendUnsubscribeRoomGroupRequest(lua_State* L ) {
	
	MOAILuaState state ( L );
    
	NSString* groupId = [[ NSString alloc ] initWithUTF8String:state.GetValue < cc8* >( 1, nil ) ];
	[MOAISmartFoxIOS::Get ().mSmartFox send:[UnsubscribeRoomGroupRequest requestWithGroupId:groupId] ];
    
}



//================================================================//
// MOAISmartFoxIOS
//================================================================//

//----------------------------------------------------------------//
MOAISmartFoxIOS::MOAISmartFoxIOS () {
    
	RTTI_SINGLE ( MOAILuaObject )
	RTTI_SINGLE ( MOAIGlobalEventSource )	

	mSmartFoxDelgate = [[ MoaiSmartFoxDelegate alloc ] init];
	
}

//----------------------------------------------------------------//
MOAISmartFoxIOS::~MOAISmartFoxIOS () {
    
    [ mSmartFoxDelgate release];    
}

//----------------------------------------------------------------//
void MOAISmartFoxIOS::RegisterLuaClass ( MOAILuaState& state ) {
    
	state.SetField ( -1, "ON_CONNECTION",       ( u32 )ON_CONNECTION );
	state.SetField ( -1, "ON_CONNECTION_LOST",	( u32 )ON_CONNECTION_LOST );
	state.SetField ( -1, "ON_CONNECTION_RETRY",       ( u32 )ON_CONNECTION_RETRY );
	state.SetField ( -1, "ON_CONNECTION_RESUME",	( u32 )ON_CONNECTION_RESUME );
	state.SetField ( -1, "ON_LOGIN",				( u32 )ON_LOGIN );
	state.SetField ( -1, "ON_LOGOUT",				( u32 )ON_LOGOUT );	
	
	state.SetField ( -1, "ON_ROOM_JOIN",			( u32 )ON_ROOM_JOIN );
	state.SetField ( -1, "ON_ROOM_JOIN_ERROR",		( u32 )ON_ROOM_JOIN_ERROR );
	state.SetField ( -1, "ON_USER_ENTER_ROOM",		( u32 )ON_USER_ENTER_ROOM );
	state.SetField ( -1, "ON_USER_EXIT_ROOM",		( u32 )ON_USER_EXIT_ROOM );
	state.SetField ( -1, "ON_USER_COUNT_CHANGE",	( u32 )ON_USER_COUNT_CHANGE );
	state.SetField ( -1, "ON_ROOM_ADD",				( u32 )ON_ROOM_ADD );
	state.SetField ( -1, "ON_ROOM_REMOVE",			( u32 )ON_ROOM_REMOVE );
	state.SetField ( -1, "ON_PUBLIC_MESSAGE",		( u32 )ON_PUBLIC_MESSAGE );
	state.SetField ( -1, "ON_PRIVATE_MESSAGE",		( u32 )ON_PRIVATE_MESSAGE );
	state.SetField ( -1, "ON_ROOM_CREATION_ERROR",	( u32 )ON_ROOM_CREATION_ERROR );
	state.SetField ( -1, "ON_ROOM_VARIABLES_UDATE",	( u32 )ON_ROOM_VARIABLES_UDATE );
	state.SetField ( -1, "ON_OBJECT_MESSAGE",		( u32 )ON_OBJECT_MESSAGE );
	state.SetField ( -1, "ON_EXTENSION_RESPONSE",	( u32 )ON_EXTENSION_RESPONSE );

	state.SetField ( -1, "ON_ROOM_FIND_RESULT",		( u32 )ON_ROOM_FIND_RESULT );

    state.SetField ( -1, "ON_INVITATION",	( u32 )ON_INVITATION );
	state.SetField ( -1, "ON_INVITATION_REPLY",	( u32 )ON_INVITATION_REPLY );
	state.SetField ( -1, "ON_INVITATION_REPLY_ERROR",	( u32 )ON_INVITATION_REPLY_ERROR );

	state.SetField ( -1, "ON_BUDDY_MESSAGE",	( u32 )ON_BUDDY_MESSAGE );
	state.SetField ( -1, "ON_BUDDY_LIST_INIT",	( u32 )ON_BUDDY_LIST_INIT );
	state.SetField ( -1, "ON_BUDDY_ADD",	( u32 )ON_BUDDY_ADD );
	state.SetField ( -1, "ON_BUDDY_REMOVE",	( u32 )ON_BUDDY_REMOVE );
	state.SetField ( -1, "ON_BUDDY_BLOCK",	( u32 )ON_BUDDY_BLOCK );
	state.SetField ( -1, "ON_BUDDY_ONLINE_STATUS_UPDATE",	( u32 )ON_BUDDY_ONLINE_STATUS_UPDATE );
	state.SetField ( -1, "ON_BUDDY_VARIABLE_UPDATE",	( u32 )ON_BUDDY_VARIABLE_UPDATE );
	state.SetField ( -1, "ON_BUDDY_ERROR",	( u32 )ON_BUDDY_ERROR );

	state.SetField ( -1, "ON_SPECTATOR_TO_PLAYER",	( u32 )ON_SPECTATOR_TO_PLAYER );
	state.SetField ( -1, "ON_SPECTATOR_TO_PLAYER_ERROR",	( u32 )ON_SPECTATOR_TO_PLAYER_ERROR );
	state.SetField ( -1, "ON_PLAYER_TO_SPECTATOR",	( u32 )ON_PLAYER_TO_SPECTATOR );
	state.SetField ( -1, "ON_PLAYER_TO_SPECTATOR_ERROR",	( u32 )ON_PLAYER_TO_SPECTATOR_ERROR );

	state.SetField ( -1, "ON_SUBSCRIBE_ROOM_GROUP",	( u32 )ON_SUBSCRIBE_ROOM_GROUP );
	state.SetField ( -1, "ON_SUBSCRIBE_ROOM_GROUP_ERROR",	( u32 )ON_SUBSCRIBE_ROOM_GROUP_ERROR );
	state.SetField ( -1, "ON_UNSUBSCRIBE_ROOM_GROUP",	( u32 )ON_UNSUBSCRIBE_ROOM_GROUP );
	state.SetField ( -1, "ON_UNSUBSCRIBE_ROOM_GROUP_ERROR",	( u32 )ON_UNSUBSCRIBE_ROOM_GROUP_ERROR );
    
    
	state.SetField ( -1, "BOOL_MATCH_EQUALS",		( u32 )BOOL_MATCH_EQUALS );
	state.SetField ( -1, "BOOL_MATCH_NOT_EQUALS",	( u32 )BOOL_MATCH_NOT_EQUALS );
	state.SetField ( -1, "NUMBER_MATCH_EQUALS",		( u32 )NUMBER_MATCH_EQUALS );
	state.SetField ( -1, "NUMBER_MATCH_NOT_EQUALS",		( u32 )NUMBER_MATCH_NOT_EQUALS );
	state.SetField ( -1, "NUMBER_MATCH_GREATER_THAN",	( u32 )NUMBER_MATCH_GREATER_THAN );
	state.SetField ( -1, "NUMBER_MATCH_GREATER_THAN_OR_EQUAL_TO",	( u32 )NUMBER_MATCH_GREATER_THAN_OR_EQUAL_TO );
	state.SetField ( -1, "NUMBER_MATCH_LESS_THAN",		( u32 )NUMBER_MATCH_LESS_THAN );
	state.SetField ( -1, "NUMBER_MATCH_LESS_THAN_OR_EQUAL_TO",	( u32 )NUMBER_MATCH_LESS_THAN_OR_EQUAL_TO );
	state.SetField ( -1, "STRING_MATCH_EQUALS",	( u32 )STRING_MATCH_EQUALS );
	state.SetField ( -1, "STRING_MATCH_NOT_EQUALS",		( u32 )STRING_MATCH_NOT_EQUALS );
	state.SetField ( -1, "STRING_MATCH_CONTAINS",	( u32 )STRING_MATCH_CONTAINS );
	state.SetField ( -1, "STRING_MATCH_STARTS_WITH",	( u32 )STRING_MATCH_STARTS_WITH );
	state.SetField ( -1, "STRING_MATCH_ENDS_WITH",	( u32 )STRING_MATCH_ENDS_WITH );
	
	
	luaL_Reg regTable[] = {
		{ "init",					_init },
		{ "initWithSocket",			_initWithSocket },
		{ "login",					_login },
		{ "sendLogoutRequest",       _sendLogoutRequest },
		{ "connect",				_connect },
		{ "isConnected",			_isConnected },
		{ "sendPublicMessageRequest",		_sendPublicMessageRequest},
		{ "sendJoinRoomRequest",	_sendJoinRoomRequest},		
		{ "setListener",			&MOAIGlobalEventSource::_setListener < MOAISmartFoxIOS > },
		{ "sendRoomVariablesRequest",      _sendRoomVariablesRequest},
		{ "sendUserVariablesRequest",      _sendUserVariablesRequest},
		{ "sendObjectMessageRequest", _sendObjectMessageRequest},
		{ "sendQuickJoinGameRequest", _sendQuickJoinGameRequest},
		{ "sendLeaveRoomRequest", _sendLeaveRoomRequest},
		{ "sendExtensionRequest", _sendExtensionRequest},
		{ "sendInitBuddyListRequest", _sendInitBuddyListRequest},		
		{ "sendAddBuddyRequest",	_sendAddBuddyRequest},
		{ "sendRemoveBuddyRequest", _sendRemoveBuddyRequest},
		{ "sendBlockBuddyRequest",	_sendBlockBuddyRequest},
		{ "sendGoOnlineRequest",	_sendGoOnlineRequest},
		{ "sendSetBuddyVariablesRequest",	_sendSetBuddyVariablesRequest},
		{ "sendPlayerToSpectatorRequest", _sendPlayerToSpectatorRequest},
		{ "sendSpectatorToPlayerRequest", _sendSpectatorToPlayerRequest},
		{ "sendFindRoomsRequest", _sendFindRoomsRequest},
		{ "sendSubscribeRoomGroupRequest", _sendSubscribeRoomGroupRequest},
		{ "sendUnsubscribeRoomGroupRequest", _sendUnsubscribeRoomGroupRequest},
		{ NULL, NULL }	
	};
    
	luaL_register ( state, 0, regTable );
}


//-------------------------------------------------------------
void MOAISmartFoxIOS::Connection(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();

	if ( this->PushListener ( ON_CONNECTION, state )) {

        if ([[evt.params objectForKey:@"success"] boolValue])
        {
            NSLog(@"Connection was established");
        }
        else
        {
            NSLog(@"Connection failed");
        }
        
        state.Push ( [[evt.params objectForKey:@"success"] boolValue] );

		state.DebugCall ( 1, 0 );
	}
	
}




void MOAISmartFoxIOS::ConnectionLost(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_CONNECTION_LOST, state )) {
		
        NSLog(@"Connection was lost, Reason: %@", [evt.params objectForKey:@"reason"]);
    
        NSString* reason = [evt.params objectForKey:@"reason"];

        state.Push ( [ reason UTF8String ] );
		state.DebugCall ( 1, 0 );
	}
	
}

void MOAISmartFoxIOS::ConnectionRetry(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_CONNECTION_RETRY, state )) {
		
       // state.Push ( [ reason UTF8String ] );
		state.DebugCall ( 0, 0 );
	}
	
}


void MOAISmartFoxIOS::Logout(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_LOGOUT, state )) {
		
		// state.Push ( [ reason UTF8String ] );
		state.DebugCall ( 0, 0 );
	}
	
}



void MOAISmartFoxIOS::ConnectionResume(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_CONNECTION_RESUME, state )) {
		
        //state.Push ( [ reason UTF8String ] );
		state.DebugCall ( 0, 0 );
	}
	
}

void MOAISmartFoxIOS::Login(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_LOGIN, state )) {
		
		
		NSLog(@"Hi, I have just logged in as: %@", [[evt.params objectForKey:@"user"] name]);
		NSLog(@"Hi, I am in zone: %@", [evt.params objectForKey:@"zone"]);
		
		state.DebugCall ( 0, 0 );
	}
}

void MOAISmartFoxIOS::LoginError(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_LOGIN_ERROR, state )) {
		
        NSLog(@"Login Failed. Reason: %@" ,[evt.params objectForKey:@"errorMessage"]);
        
		state.DebugCall ( 0, 0 );
	}
}


void MOAISmartFoxIOS::RoomJoin(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_ROOM_JOIN, state )) {
	
		lua_newtable ( state );
		
		SFSRoom *room = [evt.params objectForKey:@"room"];
		NSLog(@"The Room %@ was successfully joined!", room.name);
		
		// save the room reference for later logout
		MOAISmartFoxIOS::Get ().mCurrentRoom = room;
		
		NSArray* players = [room userList];
		
		if ( [room isGame] )
		{
			NSLog(@"is game");
		}
		else{
			NSLog(@"is not game");
		}
		
		state.SetField ( -1, "name", [ room.name UTF8String ]);
		state.SetField ( -1, "groupId", [ room.groupId	UTF8String ]);
		state.SetField ( -1, "id", room.id);
				
		NSLog(@"about to count players %i", [room userCount]);
		
		lua_pushstring ( state, "userList" );
		lua_newtable ( state );
		
		// interate through the player list
		int count = 1;
		for ( SFSUser* player in players ) {
				
			lua_pushnumber ( state, count++ );
			lua_newtable ( state );
		
			//state.SetField ( -1, "id", [ player  ]);
            
            if ( [room isGame] ){
                state.SetField ( -1, "playerId", player.playerId);
            }
                
			state.SetField ( -1, "name", [ player.name UTF8String ]);
			state.SetField ( -1, "id",  player.id  );
			state.SetField ( -1, "isItMe", player.isItMe);
			state.SetField ( -1, "isSpectator", player.isSpectator);
			
            lua_pushstring ( state, "userVariables" );
            lua_newtable ( state );
            
            // get the variables for this player
            NSArray* userVariables = [player getVariables];
            
            int variableCount = 1;
            for ( SFSUserVariable* variable in userVariables ) {
                
                NSLog(@"about to get user variable named %@", variable.name);
                
                //lua_newtable ( state );
                //lua_pushstring ( state, [variable.name UTF8String ]);
                
                if (variable.type == @"String"){
                    
                    NSLog(@"got value for variable %@", [variable getStringValue]);
                    
                    //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                    state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
                }
                
                if (variable.type == @"Int"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
                }
                
                if (variable.type == @"Bool"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
                }
                
                if (variable.type == @"Double"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
                }
                
                //lua_settable ( state, -3 );
                
            }
            
            // end user variables table
            lua_settable ( state, -3 );
            
            
			printf("set table");
			
            // end player table
			lua_settable ( state, -3 );
			
		}
		
		lua_settable ( state, -3 );
		
		NSArray* variables = [room getVariables];

        lua_pushstring ( state, "roomVariables" );
        lua_newtable ( state );
        
		int count2 = 1;
		for ( SFSRoomVariable* variable in variables ) {
			
            NSLog(@"about to get room variable named %@", variable.name);
            
            //lua_newtable ( state );
            //lua_pushstring ( state, [variable.name UTF8String ]);
            
            if (variable.type == @"String"){
                
                NSLog(@"got value for variable %@", [variable getStringValue]);
                
                //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
            }
            
            if (variable.type == @"Int"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
            }
            
            if (variable.type == @"Bool"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
            }
            
            if (variable.type == @"Double"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
            }
		}
		
        // end room variable table
        lua_settable ( state, -3 );
        
		NSLog(@"calling back with count %i", count);
		
		state.DebugCall ( 1, 0 );
	}
    
}

void MOAISmartFoxIOS::RoomJoinError(SFSEvent *evt)
{

	MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	// get all the users from the
	if ( this->PushListener ( ON_ROOM_JOIN_ERROR, state )) {
	
        
        NSLog(@"Join Room Failure:  %@", [evt.params objectForKey:@"errorMessage"]);
        
		state.DebugCall ( 0, 0 );
	}
}

void MOAISmartFoxIOS::UserEnterRoom(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_USER_ENTER_ROOM, state )) {

		lua_newtable ( state );
		
		SFSRoom *room = [evt.params objectForKey:@"room"];
		
		lua_pushstring ( state, "room" );
		lua_newtable ( state );
				
		state.SetField ( -1, "name", [ room.name UTF8String ]);
		state.SetField ( -1, "groupId", [ room.groupId	UTF8String ]);
		state.SetField ( -1, "id", room.id);
		
		// end user variables table
        lua_settable ( state, -3 );

		lua_pushstring ( state, "user" );
		lua_newtable ( state );
	
		//lua_pushnumber ( state, 1 );
		//lua_newtable ( state );
		
		SFSUser *user = [evt.params objectForKey:@"user"];
		
		// interate through the player list
		
		if ( [room isGame] ){
			state.SetField ( -1, "playerId", user.playerId);
            NSLog(@"playerid: %i", user.playerId);
		}
		
		state.SetField ( -1, "name", [ user.name UTF8String ]);
		state.SetField ( -1, "id",  user.id  );
		
		NSLog(@"id: %i isitme: %i", user.id, user.isItMe);
		
		state.SetField ( -1, "isItMe", user.isItMe);
		state.SetField ( -1, "isSpectator", user.isSpectator);
		
		NSLog(@"User: %@ has just joined Room: %@", user.name, room.name);
		
        lua_pushstring ( state, "userVariables" );
        lua_newtable ( state );
        
        // get the variables for this player
        NSArray* userVariables = [user getVariables];
        
        int variableCount = 1;
        for ( SFSUserVariable* variable in userVariables ) {
            
            NSLog(@"about to get variable named %@", variable.name);
            
            //lua_newtable ( state );
            //lua_pushstring ( state, [variable.name UTF8String ]);
            
            if (variable.type == @"String"){
                
                NSLog(@"got value for variable %@", [variable getStringValue]);
                
                //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
            }
            
            if (variable.type == @"Int"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
            }
            
            if (variable.type == @"Bool"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
            }
            
            if (variable.type == @"Double"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
            }
            
            //lua_settable ( state, -3 );
            
        }
        
        // end user variables table
        lua_settable ( state, -3 );
		
		// end result  table
        lua_settable ( state, -3 );
		
		
		NSLog(@"about to do debug call");
		
		state.DebugCall ( 1, 0 );
	}
}

void MOAISmartFoxIOS::UserExitRoom(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();

	if ( this->PushListener ( ON_USER_EXIT_ROOM, state )) {

		SFSRoom *room = [evt.params objectForKey:@"room"];
		
		lua_newtable ( state );
		//lua_pushstring ( state, "user" );
		//lua_newtable ( state );
		
		
		lua_pushstring ( state, "room" );
		lua_newtable ( state );
		
		state.SetField ( -1, "name", [ room.name UTF8String ]);
		state.SetField ( -1, "groupId", [ room.groupId	UTF8String ]);
		state.SetField ( -1, "id", room.id);
		
		// end user variables table
        lua_settable ( state, -3 );
		
		lua_pushstring ( state, "user" );
		lua_newtable ( state );
		
		SFSUser *user = [evt.params objectForKey:@"user"];

		
		if ( [room isGame] ){
			state.SetField ( -1, "playerId", user.playerId);
            NSLog(@"playerid: %i", user.playerId);
        }
    
		// interate through the player list
		state.SetField ( -1, "name", [ user.name UTF8String ]);
		state.SetField ( -1, "id",  user.id  );
		
		
		NSLog(@"id: %i isitme: %i", user.id, user.isItMe);
		
		state.SetField ( -1, "isItMe", user.isItMe);
		state.SetField ( -1, "isSpectator", user.isSpectator);
		
		//lua_settable ( state, -3 );
		//lua_settable ( state, -3 );
		
		NSLog(@"User: %@ has just left Room: %@", user.name, room.name);

        lua_pushstring ( state, "userVariables" );
        lua_newtable ( state );
        
        // get the variables for this player
        NSArray* userVariables = [user getVariables];
        
        int variableCount = 1;
        for ( SFSUserVariable* variable in userVariables ) {
            
            NSLog(@"about to get variable named %@", variable.name);
            
            //lua_newtable ( state );
            //lua_pushstring ( state, [variable.name UTF8String ]);
            
            if (variable.type == @"String"){
                
                NSLog(@"got value for variable %@", [variable getStringValue]);
                
                //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
            }
            
            if (variable.type == @"Int"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
            }
            
            if (variable.type == @"Bool"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
            }
            
            if (variable.type == @"Double"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
            }
            
            //lua_settable ( state, -3 );
            
        }
        
        // end user variables table
        lua_settable ( state, -3 );
		
		// end result  table
        lua_settable ( state, -3 );
        
		state.DebugCall ( 1, 0 );
	}
}

void MOAISmartFoxIOS::UserCountChange(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_USER_COUNT_CHANGE, state )) {
		
		state.DebugCall ( 0, 0 );
	}
}

void MOAISmartFoxIOS::RoomAdd(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_ROOM_ADD, state )) {
		
		state.DebugCall ( 0, 0 );
	}
}

void MOAISmartFoxIOS::RoomRemove(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_ROOM_REMOVE, state )) {
		
		state.DebugCall ( 0, 0 );
	}
}
  
void MOAISmartFoxIOS::PublicMessage(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	SFSUser *sender = [evt.params objectForKey:@"sender"];
    NSLog(@"%@: %@", sender.name, [evt.params objectForKey:@"message"]);
	
	NSString* name = sender.name;
	NSString* message = [evt.params objectForKey:@"message"];
	
	if ( this->PushListener ( ON_PUBLIC_MESSAGE, state )) {
		
		state.Push ( [ name UTF8String ] );
		state.Push ( [ message UTF8String] );
		state.DebugCall ( 2, 0 );
	}
}

void MOAISmartFoxIOS::PrivateMessage(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();

	SFSUser *sender = [evt.params objectForKey:@"sender"];
    NSLog(@"%@: %@", sender.name, [evt.params objectForKey:@"message"]);
	
	NSString* name = sender.name;
	NSString* message = [evt.params objectForKey:@"message"];
	
	
	if ( this->PushListener ( ON_PRIVATE_MESSAGE, state )) {
		
		state.Push ( [ name UTF8String ] );
		state.Push ( [ message UTF8String] );
		state.DebugCall ( 2, 0 );
	}
}

void MOAISmartFoxIOS::RoomCreationError(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_ROOM_CREATION_ERROR, state )) {
		
		state.DebugCall ( 0, 0 );
	}
}

void MOAISmartFoxIOS::RoomVariablesUpdate(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_ROOM_VARIABLES_UDATE, state )) {
		
		state.DebugCall ( 0, 0 );
	}
}

void MOAISmartFoxIOS::ObjectMessage(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_OBJECT_MESSAGE, state )) {
		
		SFSObject *obj = [evt.params objectForKey:@"message"];
		
		
		// NSLog(@"Received data: %@", [obj getDump]);
		
		//NSArray* keys = [obj getKeys];
		
	//	for (NSString* object in keys) {
			// do something with object
	//		NSLog(@"object key %@", object);
		
	//	}
		
		NSString* cmd = [obj getUtfString:@"cmd"];
		NSString* message = [obj getUtfString:@"message"];
	
		// NSLog(@"command and message %@: %@", cmd, message);
		
		state.Push ( [ cmd UTF8String ] );
		state.Push ( [ message UTF8String] );
	
		state.DebugCall ( 2, 0 );
	}
}

void MOAISmartFoxIOS::ExtensionResponse(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	
	if ( this->PushListener ( ON_EXTENSION_RESPONSE, state )) {
		
		
		NSString* cmd = [evt.params objectForKey:@"cmd"];
		SFSObject *obj = [evt.params objectForKey:@"params"];		
		NSString* message = [obj getUtfString:@"message"];
		

		state.Push ( [ cmd UTF8String ] );
		state.Push ( [ message UTF8String] );
		
		state.DebugCall ( 2, 0 );
	}
}

void MOAISmartFoxIOS::Invitation(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();

	if ( this->PushListener ( ON_INVITATION, state )) {
		
	}
	
}

void MOAISmartFoxIOS::InvitationReply(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_INVITATION_REPLY, state )) {
		
	}
}

void MOAISmartFoxIOS::InvitationReplyError(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_INVITATION_REPLY_ERROR, state )) {
		
	}
}

void MOAISmartFoxIOS::BuddyMessage(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_BUDDY_MESSAGE, state )) {
		
	}
}

void MOAISmartFoxIOS::BuddyListInit(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_BUDDY_LIST_INIT, state )) {
	
		lua_newtable ( state );        
        
        lua_pushstring ( state, "buddyList" );
        lua_newtable ( state );
        
        // get the variables for this player
        NSArray* buddyList = [evt.params objectForKey:@"buddyList"];
        
        int count = 1;
        for ( SFSBuddy* buddy in buddyList ) {
   
			lua_pushnumber ( state, count++ );
			lua_newtable ( state );
            
            state.SetField ( -1, "name", [ buddy.name UTF8String ]);
            state.SetField ( -1, "state", [ buddy.state UTF8String ]);
            
            state.SetField ( -1, "isOnline", buddy.isOnline);
            state.SetField ( -1, "isBlocked", buddy.isBlocked);
            state.SetField ( -1, "isTemp", buddy.isTemp);

			lua_pushstring ( state, "userVariables" );
			lua_newtable ( state );
			
			// get the variables for this player
			NSArray* userVariables = [buddy variables];
			
			int variableCount = 1;
			for ( SFSUserVariable* variable in userVariables ) {
				
				NSLog(@"about to get variable named %@", variable.name);
				
				//lua_newtable ( state );
				//lua_pushstring ( state, [variable.name UTF8String ]);
				
				if (variable.type == @"String"){
					
					NSLog(@"got value for variable %@", [variable getStringValue]);
					
					//lua_pushstring(state, [[variable getStringValue] UTF8String]);
					state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
				}
				
				if (variable.type == @"Int"){
					
					state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
				}
				
				if (variable.type == @"Bool"){
					
					state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
				}
				
				if (variable.type == @"Double"){
					
					state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
				}
				
				//lua_settable ( state, -3 );
			}
			
			// end user variables table
			lua_settable ( state, -3 );

			// end buddy
            lua_settable ( state, -3 );
        }
        
        // end buddy list
        lua_settable ( state, -3 );
        
        state.DebugCall ( 1, 0 );
	}
}

void MOAISmartFoxIOS::BuddyAdd(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_BUDDY_ADD, state )) {
		
	}
}

void MOAISmartFoxIOS::BuddyRemove(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_BUDDY_REMOVE, state )) {
		
	}
}

void MOAISmartFoxIOS::BuddyBlock(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_BUDDY_BLOCK, state )) {
		
	}
}

void MOAISmartFoxIOS::BuddyOnlineStatusUpdate(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_BUDDY_ONLINE_STATUS_UPDATE, state )) {
		
	}
}

void MOAISmartFoxIOS::BuddyVariablesUpdate(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_BUDDY_VARIABLE_UPDATE, state )) {
		
	}
}

void MOAISmartFoxIOS::BuddyError(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_BUDDY_ERROR, state )) {
		
	}
}

void MOAISmartFoxIOS::SpectatorToPlayer(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_SPECTATOR_TO_PLAYER, state )) {

		lua_newtable ( state );
		
		SFSRoom *room = [evt.params objectForKey:@"room"];
		NSLog(@"The Room %@ was successfully joined!", room.name);
		
		// save the room reference for later logout
		MOAISmartFoxIOS::Get ().mCurrentRoom = room;
		
		NSArray* players = [room userList];
		
		if ( [room isGame] )
		{
			NSLog(@"is game");
		}
		else{
			NSLog(@"is not game");
		}
		
		state.SetField ( -1, "name", [ room.name UTF8String ]);
		state.SetField ( -1, "groupId", [ room.groupId	UTF8String ]);
		state.SetField ( -1, "id", room.id);
		
		NSLog(@"about to count players %i", [room userCount]);
		
		lua_pushstring ( state, "userList" );
		lua_newtable ( state );
		
		// interate through the player list
		int count = 1;
		for ( SFSUser* player in players ) {
			
			lua_pushnumber ( state, count++ );
			lua_newtable ( state );
			
			//state.SetField ( -1, "id", [ player  ]);
            
            if ( [room isGame] ){
                state.SetField ( -1, "playerId", player.playerId);
            }
			
			state.SetField ( -1, "name", [ player.name UTF8String ]);
			state.SetField ( -1, "id",  player.id  );
			state.SetField ( -1, "isItMe", player.isItMe);
			state.SetField ( -1, "isSpectator", player.isSpectator);
			
            lua_pushstring ( state, "userVariables" );
            lua_newtable ( state );
            
            // get the variables for this player
            NSArray* userVariables = [player getVariables];
            
            int variableCount = 1;
            for ( SFSUserVariable* variable in userVariables ) {
                
                NSLog(@"about to get user variable named %@", variable.name);
                
                //lua_newtable ( state );
                //lua_pushstring ( state, [variable.name UTF8String ]);
                
                if (variable.type == @"String"){
                    
                    NSLog(@"got value for variable %@", [variable getStringValue]);
                    
                    //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                    state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
                }
                
                if (variable.type == @"Int"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
                }
                
                if (variable.type == @"Bool"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
                }
                
                if (variable.type == @"Double"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
                }
                
                //lua_settable ( state, -3 );
                
            }
            
            // end user variables table
            lua_settable ( state, -3 );
            
            
			printf("set table");
			
            // end player table
			lua_settable ( state, -3 );
			
		}
		
		lua_settable ( state, -3 );
		
		NSArray* variables = [room getVariables];
		
        lua_pushstring ( state, "roomVariables" );
        lua_newtable ( state );
        
		int count2 = 1;
		for ( SFSRoomVariable* variable in variables ) {
			
            NSLog(@"about to get room variable named %@", variable.name);
            
            //lua_newtable ( state );
            //lua_pushstring ( state, [variable.name UTF8String ]);
            
            if (variable.type == @"String"){
                
                NSLog(@"got value for variable %@", [variable getStringValue]);
                
                //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
            }
            
            if (variable.type == @"Int"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
            }
            
            if (variable.type == @"Bool"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
            }
            
            if (variable.type == @"Double"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
            }
		}
		
        // end room variable table
        lua_settable ( state, -3 );
        
		NSLog(@"calling back with count %i", count);
		
		state.DebugCall ( 1, 0 );
		
	}
}

void MOAISmartFoxIOS::SpectatorToPlayerError(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_SPECTATOR_TO_PLAYER_ERROR, state )) {

		NSLog(@"Spectator to player error:  %@", [evt.params objectForKey:@"errorMessage"]);		
		state.DebugCall ( 0, 0 );
	}
}

void MOAISmartFoxIOS::PlayerToSpectator(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_PLAYER_TO_SPECTATOR, state )) {

		lua_newtable ( state );
		
		SFSRoom *room = [evt.params objectForKey:@"room"];
		NSLog(@"The Room %@ was successfully joined!", room.name);
		
		// save the room reference for later logout
		MOAISmartFoxIOS::Get ().mCurrentRoom = room;
		
		NSArray* players = [room userList];
		
		if ( [room isGame] )
		{
			NSLog(@"is game");
		}
		else{
			NSLog(@"is not game");
		}
		
		state.SetField ( -1, "name", [ room.name UTF8String ]);
		state.SetField ( -1, "groupId", [ room.groupId	UTF8String ]);
		state.SetField ( -1, "id", room.id);
		
		NSLog(@"about to count players %i", [room userCount]);
		
		lua_pushstring ( state, "userList" );
		lua_newtable ( state );
		
		// interate through the player list
		int count = 1;
		for ( SFSUser* player in players ) {
			
			lua_pushnumber ( state, count++ );
			lua_newtable ( state );
			
			//state.SetField ( -1, "id", [ player  ]);
            
            if ( [room isGame] ){
                state.SetField ( -1, "playerId", player.playerId);
            }
			
			state.SetField ( -1, "name", [ player.name UTF8String ]);
			state.SetField ( -1, "id",  player.id  );
			state.SetField ( -1, "isItMe", player.isItMe);
			state.SetField ( -1, "isSpectator", player.isSpectator);
			
            lua_pushstring ( state, "userVariables" );
            lua_newtable ( state );
            
            // get the variables for this player
            NSArray* userVariables = [player getVariables];
            
            int variableCount = 1;
            for ( SFSUserVariable* variable in userVariables ) {
                
                NSLog(@"about to get user variable named %@", variable.name);
                
                //lua_newtable ( state );
                //lua_pushstring ( state, [variable.name UTF8String ]);
                
                if (variable.type == @"String"){
                    
                    NSLog(@"got value for variable %@", [variable getStringValue]);
                    
                    //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                    state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
                }
                
                if (variable.type == @"Int"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
                }
                
                if (variable.type == @"Bool"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
                }
                
                if (variable.type == @"Double"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
                }
                
                //lua_settable ( state, -3 );
                
            }
            
            // end user variables table
            lua_settable ( state, -3 );
            
            
			printf("set table");
			
            // end player table
			lua_settable ( state, -3 );
			
		}
		
		lua_settable ( state, -3 );
		
		NSArray* variables = [room getVariables];
		
        lua_pushstring ( state, "roomVariables" );
        lua_newtable ( state );
        
		int count2 = 1;
		for ( SFSRoomVariable* variable in variables ) {
			
            NSLog(@"about to get room variable named %@", variable.name);
            
            //lua_newtable ( state );
            //lua_pushstring ( state, [variable.name UTF8String ]);
            
            if (variable.type == @"String"){
                
                NSLog(@"got value for variable %@", [variable getStringValue]);
                
                //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
            }
            
            if (variable.type == @"Int"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
            }
            
            if (variable.type == @"Bool"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
            }
            
            if (variable.type == @"Double"){
                
                state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
            }
		}
		
        // end room variable table
        lua_settable ( state, -3 );
        
		NSLog(@"calling back with count %i", count);
		
		state.DebugCall ( 1, 0 );
	}
}

void MOAISmartFoxIOS::PlayerToSpectatorError(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_PLAYER_TO_SPECTATOR_ERROR, state )) {
		
		NSLog(@"Player to Spectator error:  %@", [evt.params objectForKey:@"errorMessage"]);
		state.DebugCall ( 0, 0 );
		
	}
}

void MOAISmartFoxIOS::SubscribeRoomGroup(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_SUBSCRIBE_ROOM_GROUP, state )) {
	
		NSArray* newRooms = [evt.params objectForKey:@"newRooms"];
        		
		for ( SFSRoom* room in newRooms ) {
  
            NSLog(@"The Room %@ was successfully joined!", room.name);
            
            NSArray* users = [room userList];
            NSArray* players = [room playerList];
            
        }
	}
}

void MOAISmartFoxIOS::SubscribeRoomGroupError(SFSEvent *evt)
{
    
}

void MOAISmartFoxIOS::UnsubscribeRoomGroup(SFSEvent *evt)
{
    
}

void MOAISmartFoxIOS::UnsubscribeRoomGroupError(SFSEvent *evt)
{
    
}



void MOAISmartFoxIOS::RoomFindResult(SFSEvent *evt)
{
    MOAILuaStateHandle state = MOAILuaRuntime::Get ().State ();
	if ( this->PushListener ( ON_ROOM_FIND_RESULT, state )) {
	
		NSArray* rooms = [evt.params objectForKey:@"rooms"];

        lua_newtable ( state );
        
		lua_pushstring ( state, "rooms" );
		lua_newtable ( state );
		
        int roomCount = 1;
		for ( SFSRoom* room in rooms ) {
		
			lua_pushnumber ( state, roomCount++ );
			lua_newtable ( state );
            
            NSLog(@"The Room %@ was successfully joined!", room.name);
            
            NSArray* players = [room userList];
            
            if ( [room isGame] )
            {
                NSLog(@"is game");
            }
            else{
                NSLog(@"is not game");
            }
            
            state.SetField ( -1, "name", [ room.name UTF8String ]);
            state.SetField ( -1, "groupId", [ room.groupId	UTF8String ]);
            state.SetField ( -1, "id", room.id);
            
            NSLog(@"about to count players %i", [room userCount]);
            
            lua_pushstring ( state, "userList" );
            lua_newtable ( state );
            
            // interate through the player list
            int count = 1;
            for ( SFSUser* player in players ) {
                
                lua_pushnumber ( state, count++ );
                lua_newtable ( state );
                
                //state.SetField ( -1, "id", [ player  ]);
                
                if ( [room isGame] ){
                    state.SetField ( -1, "playerId", player.playerId);
                }
                
                state.SetField ( -1, "name", [ player.name UTF8String ]);
                state.SetField ( -1, "id",  player.id  );
                state.SetField ( -1, "isItMe", player.isItMe);
                state.SetField ( -1, "isSpectator", player.isSpectator);
                
                lua_pushstring ( state, "userVariables" );
                lua_newtable ( state );
                
                // get the variables for this player
                NSArray* userVariables = [player getVariables];
                
                int variableCount = 1;
                for ( SFSUserVariable* variable in userVariables ) {
                    
                    NSLog(@"about to get user variable named %@", variable.name);
                    
                    //lua_newtable ( state );
                    //lua_pushstring ( state, [variable.name UTF8String ]);
                    
                    if (variable.type == @"String"){
                        
                        NSLog(@"got value for variable %@", [variable getStringValue]);
                        
                        //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                        state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
                    }
                    
                    if (variable.type == @"Int"){
                        
                        state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
                    }
                    
                    if (variable.type == @"Bool"){
                        
                        state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
                    }
                    
                    if (variable.type == @"Double"){
                        
                        state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
                    }
                    
                    //lua_settable ( state, -3 );
                    
                }
                
                // end user variables table
                lua_settable ( state, -3 );
                
                
                printf("set table");
                
                // end player table
                lua_settable ( state, -3 );
                
            }
            
            // end player list table
            lua_settable ( state, -3 );
            
            NSArray* variables = [room getVariables];
            
            lua_pushstring ( state, "roomVariables" );
            lua_newtable ( state );
            
            int count2 = 1;
            for ( SFSRoomVariable* variable in variables ) {
                
                NSLog(@"about to get room variable named %@", variable.name);
                
                //lua_newtable ( state );
                //lua_pushstring ( state, [variable.name UTF8String ]);
                
                if (variable.type == @"String"){
                    
                    NSLog(@"got value for variable %@", [variable getStringValue]);
                    
                    //lua_pushstring(state, [[variable getStringValue] UTF8String]);
                    state.SetField ( -1, [variable.name UTF8String ], [[variable getStringValue] UTF8String]);
                }
                
                if (variable.type == @"Int"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getIntValue]);
                }
                
                if (variable.type == @"Bool"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getBoolValue]);
                }
                
                if (variable.type == @"Double"){
                    
                    state.SetField ( -1, [variable.name UTF8String ], [variable getDoubleValue]);
                }
            }
            
            // end room variables table
            lua_settable ( state, -3 );

            //end room table
            lua_settable ( state, -3 );
        }
        
        // end rooms table
		lua_settable ( state, -3 );

        NSLog(@"about to do debug call");
		state.DebugCall ( 1, 0 );
	
	}
}

//================================================================//
#pragma mark - Delagate Event handlers
//================================================================//
@implementation MoaiSmartFoxDelegate


- (void)onConnection:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().Connection ( evt );
}

- (void)onConnectionLost:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().ConnectionLost ( evt );
}

- (void)onConnectionRetry:(SFSEvent *)evt
{
    MOAISmartFoxIOS::Get ().ConnectionRetry ( evt );
}

- (void)onConnectionResume:(SFSEvent *)evt
{
    MOAISmartFoxIOS::Get ().ConnectionResume ( evt );
}

- (void)onLogin:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().Login ( evt );
}

- (void)onLoginError:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().LoginError ( evt );
}


- (void)onLogout:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().Logout( evt );
}

- (void)onRoomJoin:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().RoomJoin ( evt );
}

- (void)onRoomJoinError:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().RoomJoinError ( evt );
}

- (void)onUserEnterRoom:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().UserEnterRoom ( evt );
}

- (void)onUserExitRoom:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().UserExitRoom ( evt );
}
- (void)onUserCountChange:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().UserCountChange ( evt );
}

- (void)onRoomAdd:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().RoomAdd ( evt );
}

- (void)onRoomRemove:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().RoomRemove ( evt );
}

- (void)onPublicMessage:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().PublicMessage ( evt );
}

- (void)onPrivateMessage:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().PrivateMessage ( evt );
}

- (void)onRoomCreationError:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().RoomCreationError ( evt );
}

- (void)onRoomVariablesUpdate:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().RoomVariablesUpdate ( evt );
}

- (void)onObjectMessage:(SFSEvent *)evt
{
   MOAISmartFoxIOS::Get ().ObjectMessage ( evt );
}

- (void)onExtensionResponse:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().ExtensionResponse( evt );
}

- (void)onBuddyMessage:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().BuddyMessage( evt );
}

- (void)onBuddyListInit:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().BuddyListInit( evt );
}

- (void)onBuddyAdd:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().BuddyAdd( evt );
}

- (void)onBuddyRemove:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().BuddyRemove( evt );
}

- (void)onBuddyBlock:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().BuddyBlock( evt );
}

- (void)onBuddyOnlineStatusUpdate:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().BuddyOnlineStatusUpdate( evt );
}

- (void)onBuddyVariablesUpdate:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().BuddyVariablesUpdate( evt );
}

- (void)onBuddyError:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().BuddyError( evt );
}

- (void)onInvitation:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().Invitation( evt );
}

- (void)onInvitationReply:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().InvitationReply( evt );
}

- (void)onInvitationReplyError:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().InvitationReplyError( evt );
}

- (void)onSpectatorToPlayer:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().SpectatorToPlayer( evt );
}

- (void)onSpectatorToPlayerError:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().SpectatorToPlayerError( evt );
}

- (void)onPlayerToSpectator:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().PlayerToSpectator( evt );
}

- (void)onPlayerToSpectatorError:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().PlayerToSpectatorError( evt );
}

- (void)onRoomFindResult:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().RoomFindResult( evt );
}

- (void)onSubscribeRoomGroup:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().SubscribeRoomGroup( evt );
}

- (void)onUnsubscribeRoomGroup:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().UnsubscribeRoomGroup( evt );
}

- (void)onSubscribeRoomGroupError:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().SubscribeRoomGroupError( evt );
}

- (void)onUnsubscribeRoomGroupError:(SFSEvent *)evt
{
	MOAISmartFoxIOS::Get ().UnsubscribeRoomGroup( evt );
}


@end

