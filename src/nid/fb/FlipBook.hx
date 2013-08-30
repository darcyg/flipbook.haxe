package nid.fb;

import flash.display.Sprite;
import nid.fb.gl.GLView;

/**
 * ...
 * @author Nidin Vinayakan
 */
class FlipBook extends Sprite
{

	public function new() 
	{
		super();
		var gl_view:GLView = new GLView();
		addChild(gl_view);
	}
	
}