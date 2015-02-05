package com.creativemage.swfUtils;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Alex Kolpakov
 */
enum OriginFrame
{
	First;
	Largest;
	Custom(index:Int);
}
 
 
class MovieClipRenderer
{
	// PUBLIC METHODS
	
	/**
	 * Renders the target MovieClip into an array of BitmapDatas.
	 * @param	clip - target MovieClip.
	 * @param	w - width of the clip's first frame. Other frames will be scaled accordigly and can be different in size. If unspecified it will scale proportionally to height. If both width and height are unspecified the original size will be used.
	 * @param	h - height of the clip's first frame. Other frames will be scaled accordigly and can be different in size. If unspecified it will scale proportionally to width. If both width and height are unspecified the original size will be used.
	 * @return Array of frames renderer as BitmapData.
	 */
	public static function render(clip:MovieClip, ?w:Null<Int>, ?h:Null<Int>):Array<BitmapData>
	{
		var largestOffset = getClipOffset( clip );
		var largestFrameSize = getLargestFrameSize( clip );
		
		var largestOriginalCanvasSize:Point = getLargestCanvasSize(clip);
		
		var firstFrameSize:Point = getFrameSize( 1, clip );
		
		var scaleX:Float = 0;
		var scaleY:Float = 0;
		
		if ( w == null && h == null)
		scaleX = scaleY = 1;
		else if ( w != null && h != null)
		{
			scaleX = w / firstFrameSize.x;
			scaleY = h / firstFrameSize.y;
		}
		else
		{
			if ( h == null )
				scaleX = scaleY = w / firstFrameSize.x;
			if ( w == null)
				scaleY = scaleX = h / firstFrameSize.y;
		}
		
		var clipOffset = new Point( largestOffset.x * scaleX, largestOffset.y * scaleY);
		var canvasSize:Point = new Point( largestOriginalCanvasSize.x * scaleX - clipOffset.x + 1, largestOriginalCanvasSize.y * scaleY - clipOffset.y + 1);
		
		return renderClip( clip, canvasSize, new Point( scaleX, scaleY), clipOffset);
	}
	
	// PRIVATE METHODS 
	
	static private function getLargestCanvasSize(clip:MovieClip):Point 
	{
		resetMovie(clip);
		var largestSize:Point = new Point();
		
		for ( i in 1...clip.totalFrames + 1)
		{
			var b = clip.getBounds(clip);
			var combinedWidth:Float = b.x + b.width;
			var combinedHeight:Float = b.y + b.height;
			
			if ( combinedWidth > largestSize.x)
			largestSize.x = combinedWidth;
			
			if ( combinedHeight > largestSize.y)
			largestSize.y = combinedHeight;
			
			getNextFrame(clip);
		}
		
		return largestSize;
	}
	
	private static function renderClip(clip:MovieClip, canvasSize:Point, clipScale:Point, offset:Point):Array<BitmapData>
	{
		var bdArray:Array<BitmapData> = [];
		
		var m:Matrix = new Matrix();
		m.scale( clipScale.x, clipScale.y );
		m.translate( -offset.x , -offset.y);
		
		resetMovie(clip);
		
		for ( i in 1...clip.totalFrames + 1)
		{
			var bd:BitmapData = new BitmapData( cast canvasSize.x, cast canvasSize.y, false, 0xFF);
			bd.draw( clip, m);
			
			bdArray.push(bd);
			getNextFrame(clip);
		}
		
		resetMovie(clip);
		return bdArray;
	}
	
	static private function getFrameSize(frame:Int, clip:MovieClip):Point 
	{
		if (frame < 1) frame = 1;
			
		resetMovie(clip);
		for ( i in 1...frame)
		getNextFrame( clip );
		var bounds = clip.getBounds(clip);
		
		return new Point( bounds.width, bounds.height );
		
	}
	
	static private function getFrameOffset(clip:MovieClip, frame:Int):Point
	{
		resetMovie(clip);
		if ( frame < 1 ) frame = 1;
		
		for ( i in 1...frame)
			getNextFrame(clip);
			
		var bounds = clip.getBounds(clip);
		return new Point( bounds.x, bounds.y );
	}
	
	static private function getClipOffset(clip:MovieClip):Point
	{
		resetMovie(clip);
		
		var bounds:Rectangle = clip.getBounds(clip);
		
		var offsetX:Float = bounds.x;
		var offsetY:Float = bounds.y;
		
		
		for ( i in 1...clip.totalFrames + 1)
		{
			bounds = clip.getBounds(clip);
			
			if ( bounds.x < offsetX )
			offsetX = bounds.x;
			
			if ( bounds.y < offsetY )
			offsetY = bounds.y;
			
			getNextFrame(clip);
		}
		
		return new Point(offsetX, offsetY);
	}
	
	static private function getLargestFrameSize(clip:MovieClip):Point
	{
		var size:Point = new Point();
		resetMovie(clip);
		
		for ( i in 1...clip.totalFrames + 1)
		{
			size.x = (size.x < clip.width) ? clip.width : size.x;
			size.y = (size.y < clip.height) ? clip.height : size.y;
			
			getNextFrame(clip);
		}
		
		return size;
	}
	
	private static function getNextFrame(clip:MovieClip):Void 
	{
		var nextFrame:Int = (clip.currentFrame + 1) % (clip.totalFrames + 1);
		
		if (nextFrame == 0)
			nextFrame = 1;
		
		clip.gotoAndStop( nextFrame );
		
		for ( i in 0...clip.numChildren)
		{
			var child = clip.getChildAt(i);
			
			if ( Std.is( child, MovieClip) == true )
				getNextFrame(cast child);
		}
	}
	
	private static function resetMovie(clip:MovieClip):Void
	{
		clip.gotoAndStop( 1);
		
		for ( i in 0...clip.numChildren)
		{
			var child = clip.getChildAt(i);
			
			if ( Std.is( child, MovieClip) == true )
				resetMovie(cast child);
		}
	}
	
}