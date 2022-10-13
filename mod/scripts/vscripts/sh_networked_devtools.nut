untyped

global function DevTools_Network
global function TraceFromEnt
global function DrawNetwork
global function ReplacedCommand
#if CLIENT
global function RegisterDrawParams

struct {
	array<var> drawPassedParams
} file
#elseif SERVER
global function DrawGlobal
#endif

string function ReplacedCommand( string cmd )
{
	string msg = cmd
	while( msg.find("@me") != null )
		msg = StringReplace( msg, "@me", "executor")
	while( msg.find("@all") != null )
		msg = StringReplace( msg, "@all", "GetPlayerArray()" )
	while( msg.find("@us") != null )
		msg = StringReplace( msg, "@us", "GetPlayerArrayOfTeam(executor.GetTeam())")
	while( msg.find("@that") != null )
		msg = StringReplace( msg, "@that", "TraceFromEnt(executor).hitEnt" )
	while( msg.find("@there") != null )
		msg = StringReplace( msg, "@there", "TraceFromEnt(executor).endPos" )
	while( msg.find("@trace") != null )
		msg = StringReplace( msg, "@trace", "TraceFromEnt(executor)" )
	while( msg.find("@here") != null )
		msg = StringReplace( msg, "@here", "executor.GetOrigin()" )
	while( msg.find("@cache") != null)
		msg = StringReplace( msg, "@cache", "sel(executor)")
	while( msg.find("#") != null )
		msg = StringReplace( msg, "#", "GetEntByScriptName" )
	return msg
}

void function DevTools_Network()
{
	AddCallback_OnRegisteringCustomNetworkVars( RegisterNetworkVars )
}

void function RegisterNetworkVars()
{
    Remote_RegisterFunction( "DrawNetwork" )
	Remote_RegisterFunction( "RegisterDrawParams" )

	#if CLIENT
	AddServerToClientStringCommandCallback( "scc", ServerCommandCLIENTScriptSafeCallback )
	AddServerToClientStringCommandCallback( "suc", ServerCommandUIScriptSafeCallback )
	#endif
}

int function GetDrawID( string type )
{
	switch( type )
	{
		case "DebugDrawCircle":
		case "circle":
			return 0
		case "DebugDrawCylinder":
		case "cylinder":
			return 1
		case "DebugDrawAngles":
		case "angles":
			return 2
		case "DebugDrawSphere":
		case "sphere":
			return 3
		case "DebugDrawText":
		case "text":
			return 4
		case "DebugDrawBox":
		case "box":
			return 5
		case "DebugDrawBoxSimple":
		case "boxsimple":
			return 6
		case "DebugDrawCube":
		case "cube":
			return 7
		case "DebugDrawCircleTillSignal":
		case "circletillsignal":
			return 8
		case "DebugDrawOriginMovement":
		case "originmovement":
			return 9
		case "DebugDrawTrigger":
		case "trigger":
			return 10
		case "DebugDrawMark":
		case "mark":
			return 11
		case "DebugDrawSpawnpoint":
		case "spawnpoint":
			return 12
		case "DebugDrawCircleOnEnt":
		case "circleonent":
			return 13
		case "DebugDrawSphereOnEnt":
		case "sphereonent":
			return 14
		case "DebugDrawCircleOnTag":
		case "circleontag":
			return 15
		case "DebugDrawSphereOnTag":
		case "sphereontag":
			return 16
		case "DebugDrawWeapon":
		case "weapon":
			return 17
		case "DebugDrawMissilePath":
		case "missilepath":
			return 18
		case "DebugDrawRotatedBox":
		case "rotatedbox":
			return 19
		case "DebugDrawLine":
		case "line":
		default:
			return 20
	}
	unreachable
}

#if SERVER
void function DrawNetwork( entity player, string type, ... )
{
	if ( vargc <= 0 )
		return

	array args = [ this, player, "DrawNetwork", GetDrawID( type ) ]
	for ( int i = 0; i < vargc; i++)
	{
		if ( typeof vargv[i] == "vector" )
		{
			Remote_CallFunction_NonReplay( player, "RegisterDrawParams", vargv[i].x, vargv[i].y, vargv[i].z )
			args.append( 0x99999999 )
		}
		else if ( typeof vargv[i] == "entity" )
		{
			Remote_CallFunction_NonReplay( player, "RegisterDrawParams", vargv[i].GetEncodedEHandle() )
			args.append( 0x99999999 )
		}
		else
			args.append( vargv[i] )
	}

	Remote_CallFunction_NonReplay.acall( args )
}

void function DrawGlobal( string type, ... )
{
	if ( vargc <= 0 )
		return

	array args = [ type ]
	for ( int i = 0; i < vargc; i++)
		args.append( vargv[i] )

	foreach( entity player in GetPlayerArray() )
	{
		array temp = args
		temp.insert( 0, player )
		temp.insert( 0, this )
		DrawNetwork.acall( temp )
	}
}
#endif

#if CLIENT
void function RegisterDrawParams( float x, float y, float z )
{
	file.drawPassedParams.append( <x,y,z> )
}

void function DrawNetwork( string type, ... )
{
	if ( vargc <= 0 )
		return

	array args = [ this ]
	int networkedVectors
	for ( int i = 0; i < vargc; i++)
	{
		if ( vargv[i] == 0x99999999 )
		{
			var param = file.drawPassedParams[ networkedVectors ]
			args.append( typeof param == "int" ? GetEntityFromEncodedEHandle( expect int( param ) ) : param )
			networkedVectors++
		}
		else
			args.append( vargv[i] )
	}
	file.drawPassedParams.clear()
	switch( type )
		{
			case 0:
				DebugDrawCircle.acall( args )
				break
			case 1:
				DebugDrawCylinder.acall( args )
				break
			case 2:
				DebugDrawAngles.acall( args )
				break
			case 3:
				DebugDrawSphere.acall( args )
				break
			case 4:
				DebugDrawText.acall( args )
				break
			case 5:
				DebugDrawBox.acall( args )
				break
			case 6:
				DebugDrawBoxSimple.acall( args )
				break
			case 7:
				DebugDrawCube.acall( args )
				break
			case 8:
				DebugDrawCircleTillSignal.acall( args )
				break
			case 9:
				DebugDrawOriginMovement.acall( args )
				break
			case 10:
				DebugDrawTrigger.acall( args )
				break
			case 11:
				DebugDrawMark.acall( args )
				break
			case 12:
				DebugDrawSpawnpoint.acall( args )
				break
			case 13:
				DebugDrawCircleOnEnt.acall( args )
				break
			case 14:
				DebugDrawSphereOnEnt.acall( args )
				break
			case 15:
				DebugDrawCircleOnTag.acall( args )
				break
			case 16:
				DebugDrawSphereOnTag.acall( args )
				break
			case 17:
				DebugDrawWeapon.acall( args )
				break
			case 18:
				DebugDrawMissilePath.acall( args )
				break
			case 19:
				DebugDrawRotatedBox.acall( args )
				break
			case 20:
			default:
				DebugDrawLine.acall( args )
				break
		}
}

void function ServerCommandCLIENTScriptSafeCallback( array<string> args )
{
	string msg = ReplacedCommand( StringReplace( CombineArgs( args ), ":", ";" ) )
	entity executor = GetLocalClientPlayer()
	errcall( "printinexplicit(" + msg + ")" )
}

void function ServerCommandUIScriptSafeCallback( array<string> args )
{
	string msg = ReplacedCommand( StringReplace( CombineArgs( args ), ":", ";" ) )
	entity executor = GetLocalClientPlayer()
	errcall( "printinexplicit(" + msg + ")" )
}
#endif

TraceResults function TraceFromEnt( entity p )
{
	TraceResults traceResults = TraceLineHighDetail( p.EyePosition(),
	p.EyePosition() + p.GetViewVector() * 10000,
	p, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	return traceResults
}