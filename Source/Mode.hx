package;

import addonsTests.CaveGeneratorTest;
import org.flixel.FlxGame;
	
class Mode extends FlxGame
{
	
	#if flash
	public static var SoundExtension:String = ".mp3";
	#elseif cpp
	public static var SoundExtension:String = ".wav";
	#else
	public static var SoundExtension:String = ".ogg";
	#end
	
	public static var SoundOn:Bool = true;
	
	public function new()
	{
		super(320, 240, MenuState, 2, 60, 60);
		//super(320, 240, CaveGeneratorTest, 2, 50, 50);
		forceDebugger = true;
	}
}
