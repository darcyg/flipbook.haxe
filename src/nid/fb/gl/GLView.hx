package nid.fb.gl;


import flash.display.Sprite;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import openfl.display.OpenGLView;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl.utils.Float32Array;


class GLView extends Sprite {
	
	
	private var shaderProgram:GLProgram;
	private var vertexAttribute:Int;
	private var vertexBuffer:GLBuffer;
	private var view:OpenGLView;
	
	
	public function new () {
		
		super ();
		
		if (OpenGLView.isSupported) {
			
			view = new OpenGLView ();
			
			createProgram ();
			
			var vertices = [
				-0.5, -0.5, 0.0,	// Lower-left
				0.5 , -0.5, 0.0,	// Lower-right
				0.0 , 0.5 , 0.0,	// Top
				//Colors
				1.0, 0.0, 0.0, 1.0, 
				0.0, 1.0, 0.0, 1.0,
				0.0, 0.0, 1.0, 1.0
			];
			
			var colors = [
				1.0, 0.0, 0.0, 1.0, 
				0.0, 1.0, 0.0, 1.0,
				0.0, 0.0, 1.0, 1.0
				];
			
			vertexBuffer = GL.createBuffer ();
			GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);	
			GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast vertices), GL.STATIC_DRAW);
			GL.bindBuffer (GL.ARRAY_BUFFER, null);
			
			view.render = renderView;
			addChild (view);
			
		}
		
	}
	
	
	private function createProgram ():Void {
		
		/*var vertexShaderSource = 
			
			"attribute vec3 vertexPosition;
			
			uniform mat4 modelViewMatrix;
			uniform mat4 projectionMatrix;
			
			void main(void) {
				gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
			}";*/
			
			var vertexShaderSource = 
			
			"vec4 s_vPosition;
			vec4 s_vColor;
			vec4 color;
			//uniform mat4 s_mM;	// The matrix for the pose of the model
			//uniform mat4 s_mV;	// The matrix for the pose of the camera
			//uniform mat4 s_mP;	// The perspective matrix
			void main () {
				// Look, Ma!  I avoided any matrix multiplication!
				// The value of s_vPosition should be between -1.0 and +1.0 (to be visible on the screen)
				//gl_Position = s_mP*s_mV*s_mM*s_vPosition;
				color = s_vColor;
				gl_Position = s_vPosition;
			}";
		
		var vertexShader = GL.createShader (GL.VERTEX_SHADER);
		GL.shaderSource (vertexShader, vertexShaderSource);
		GL.compileShader (vertexShader);
		
		if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0) {
			
			throw "Error compiling vertex shader";
			
		}
		
		/*var fragmentShaderSource = 
			
			"void main(void) {
				gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
			}";*/
		var fragmentShaderSource = 
			
			"vec4 s_vColor;
			 void main () {
				// No matter what, color the pixel red!
				gl_FragColor = vec4 (1.0, 0.0, 0.0, 1.0);
			 }";
		
		var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
		GL.shaderSource (fragmentShader, fragmentShaderSource);
		GL.compileShader (fragmentShader);
		
		if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0) {
			
			throw "Error compiling fragment shader";
			
		}
		
		shaderProgram = GL.createProgram ();
		GL.attachShader (shaderProgram, vertexShader);
		GL.attachShader (shaderProgram, fragmentShader);
		GL.linkProgram (shaderProgram);
		
		if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0) {
			
			throw "Unable to initialize the shader program.";
			
		}
		
		vertexAttribute = GL.getAttribLocation (shaderProgram, "vertexPosition");
		
	}
	
	
	private function renderView (rect:Rectangle):Void {
		
		GL.viewport (Std.int (rect.x), Std.int (rect.y), Std.int (rect.width), Std.int (rect.height));
		
		GL.clearColor (8 >> 8, 146 >> 8, 208 >> 8, 1);
		GL.clear (GL.COLOR_BUFFER_BIT);
		
		var positionX = rect.width / 2;
		var positionY = rect.height / 2;
		
		var projectionMatrix = Matrix3D.createOrtho (0, rect.width, rect.height, 0, 1000, -1000);
		var modelViewMatrix = Matrix3D.create2D (positionX, positionY, 1, 0);
		
		GL.useProgram (shaderProgram);
		GL.enableVertexAttribArray (vertexAttribute);
		
		GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);
		GL.vertexAttribPointer (vertexAttribute, 3, GL.FLOAT, false, 0, 0);
		
		var projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "projectionMatrix");
		var modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "modelViewMatrix");
		
		GL.uniformMatrix3D (projectionMatrixUniform, false, projectionMatrix);
		GL.uniformMatrix3D (modelViewMatrixUniform, false, modelViewMatrix);
		
		GL.drawArrays (GL.TRIANGLE_STRIP, 0, 4);
		
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		
	}
	
	
}