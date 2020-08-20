//
//  ViewController.swift
//  GLKit-Swift
//
//  Created by Zsy on 2020/7/26.
//  Copyright © 2020 Zsy. All rights reserved.
//

import UIKit
import GLKit
import OpenGLES

class ViewController: GLKViewController {
    
    var context: EAGLContext? = nil
    var mEffect: GLKBaseEffect? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupContext()
        setupTexture()
        setupVertexData()
    }
    
    func setupContext() {
        context = EAGLContext(api: .openGLES2)
        
        if !(self.context != nil) {
            print("Failed to create ES context")
        }
        
        let view: GLKView = self.view as! GLKView;
        view.drawableColorFormat = .RGBA8888
        view.context = context!
        
        EAGLContext.setCurrent(context)
    }
    
    func setupTexture() {
        // Farewell
        let filePath = Bundle.main.path(forResource: "Farewell", ofType: "jpg")
        guard let textureInfo = try? GLKTextureLoader.texture(withContentsOfFile: filePath!, options: [GLKTextureLoaderOriginBottomLeft:NSNumber.init(integerLiteral: 1)] ) else {
            return
        }
        mEffect = GLKBaseEffect.init()
        mEffect?.texture2d0.enabled = GLboolean(GL_TRUE)
        mEffect?.texture2d0.name    = textureInfo.name
    }
    
    func setupVertexData() {
        var squareVertexData: [GLfloat] = [
            0.5, -0.5, 0.0,    1.0, 0.0, //右下
            0.5, 0.5,  0.0,    1.0, 1.0, //右上
            -0.5, 0.5, 0.0,    0.0, 1.0, //左上
            
            0.5, -0.5, 0.0,    1.0, 0.0, //右下
            -0.5, 0.5, 0.0,    0.0, 1.0, //左上
            -0.5, -0.5, 0.0,   0.0, 0.0, //左下
        ];
        
        var buffer: GLuint = 0
        glGenBuffers(1, &buffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), buffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride*squareVertexData.count, &squareVertexData, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride*5), nil)

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride*5), UnsafeMutableRawPointer(bitPattern: 3*MemoryLayout<GLfloat>.stride))
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glClearColor(1.0, 0.0, 0.0, 1.0)
        
        mEffect?.prepareToDraw()
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
    }
}
