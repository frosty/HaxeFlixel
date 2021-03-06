package addons;
import nme.geom.Matrix;
import org.flixel.FlxBasic;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Zaphod
 */

class FlxSkewedSprite extends FlxSprite
{

	public var skew:FlxPoint;
	private var _skewMatrix:Matrix;
	
	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);
		
		skew = new FlxPoint();
		_skewMatrix = new Matrix();
	}
	
	override public function destroy():Void 
	{
		skew = null;
		_skewMatrix = null;
		
		super.destroy();
	}
	
	override public function getSimpleRender():Bool
	{ 
		return (((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null) && (skew.x == 0) && (skew.y == 0));
	}
	
	override public function draw():Void 
	{
		if(_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker)
			{
				return;
			}
		}
		
		if (dirty)	//rarely 
		{
			calcFrame();
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		#if (cpp || neko)
		var currDrawData:Array<Float>;
		var currIndex:Int;
		#end
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		
		while(i < l)
		{
			camera = cameras[i++];
			
			if (!onScreen(camera))
			{
				continue;
			}
			
			#if (cpp || neko)
			currDrawData = _tileSheetData.drawData[camera.ID];
			currIndex = _tileSheetData.positionData[camera.ID];
			
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x);
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y);
			
			_point.x = (_point.x) + origin.x;
			_point.y = (_point.y) + origin.y;
			#else
			_point.x = x - Math.floor(camera.scroll.x * scrollFactor.x) - Math.floor(offset.x);
			_point.y = y - Math.floor(camera.scroll.y * scrollFactor.y) - Math.floor(offset.y);
			
			_point.x += (_point.x > 0)?0.0000001:-0.0000001;
			_point.y += (_point.y > 0)?0.0000001: -0.0000001;
			#end
			if (simpleRender)
			{	//Simple render
				#if flash
				_flashPoint.x = _point.x;
				_flashPoint.y = _point.y;
				camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, null, null, true);
				#else
				currDrawData[currIndex++] = _point.x;
				currDrawData[currIndex++] = _point.y;
				
				currDrawData[currIndex++] = _frameID;
				
				// handle reversed sprites
				if ((_flipped != 0) && (_facing == FlxObject.LEFT))
				{
					currDrawData[currIndex++] = -1;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 1;
				}
				else
				{
					currDrawData[currIndex++] = 1;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 1;
				}
				
				if (_tileSheetData.isColored || camera.isColored)
				{
					if (camera.isColored)
					{
						currDrawData[currIndex++] = _red * camera.red; 
						currDrawData[currIndex++] = _green * camera.green;
						currDrawData[currIndex++] = _blue * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = _red; 
						currDrawData[currIndex++] = _green;
						currDrawData[currIndex++] = _blue;
					}
				}
				
				currDrawData[currIndex++] = _alpha;
				
				_tileSheetData.positionData[camera.ID] = currIndex;
				#end
			}
			else
			{	//Advanced render
				_matrix.identity();
				
				#if flash
				_matrix.translate( -origin.x, -origin.y);
				if ((angle != 0) && (_bakedRotation <= 0))
				{
					_matrix.rotate(angle * 0.017453293);
				}
				_matrix.scale(scale.x, scale.y);
				if (skew.x != 0 || skew.y != 0)
				{
					_skewMatrix.identity();
					_skewMatrix.b = Math.tan(skew.y * 0.017453293);
					_skewMatrix.c = Math.tan(skew.x * 0.017453293);
					
					_matrix.concat(_skewMatrix);
				}
				
				_matrix.translate(_point.x + origin.x, _point.y + origin.y);
				camera.buffer.draw(framePixels, _matrix, null, blend, null, antialiasing);
				#else
				radians = -angle * 0.017453293;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				currDrawData[currIndex++] = _point.x;
				currDrawData[currIndex++] = _point.y;
				
				currDrawData[currIndex++] = _frameID;
				
				_matrix.a = cos;
				_matrix.b = sin;
				_matrix.c = -sin;
				_matrix.d = cos;
				
				if ((_flipped != 0) && (_facing == FlxObject.LEFT))
				{
					_matrix.scale( -scale.x, scale.y);
				}
				else
				{
					_matrix.scale(scale.x, scale.y);
				}
				
				if (skew.x != 0 || skew.y != 0)
				{
					_skewMatrix.identity();
					_skewMatrix.b = Math.tan(-skew.x * 0.017453293);
					_skewMatrix.c = Math.tan(-skew.y * 0.017453293);
					
					_matrix.concat(_skewMatrix);
				}
				
				currDrawData[currIndex++] = _matrix.a;
				currDrawData[currIndex++] = _matrix.b;
				currDrawData[currIndex++] = _matrix.c;
				currDrawData[currIndex++] = _matrix.d;
				
				if (_tileSheetData.isColored || camera.isColored)
				{
					if (camera.isColored)
					{
						currDrawData[currIndex++] = _red * camera.red; 
						currDrawData[currIndex++] = _green * camera.green;
						currDrawData[currIndex++] = _blue * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = _red; 
						currDrawData[currIndex++] = _green;
						currDrawData[currIndex++] = _blue;
					}
				}
				
				currDrawData[currIndex++] = _alpha;
				
				_tileSheetData.positionData[camera.ID] = currIndex;
				#end
			}
			FlxBasic._VISIBLECOUNT++;
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
		}
	}
	
}