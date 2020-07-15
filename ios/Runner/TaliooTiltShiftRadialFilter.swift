//
//  TaliooTiltShiftRadialFilter.swift
//  TiltShift
//
//  Created by Muis on 12/07/20.
//  Copyright © 2020 Muis. All rights reserved.
//

import Foundation
import GPUImage

final class TaliooTiltShiftRadialFilter: GPUImageFilterGroup {
    private lazy var blurFilter = GPUImageGaussianBlurFilter()
    private lazy var selectiveFocusFilter: GPUImageFilter = {
        return GPUImageTwoInputFilter(
            fragmentShaderFromFile: "TiltShiftRadialFragmentShader"
        )
    }()
    var hasOverridenAspectRatio = false
    
    var blurRadiusInPixels: CGFloat = 5.0 {
        didSet {
            blurFilter.blurRadiusInPixels = blurRadiusInPixels
        }
    }
    var excludeCircleRadius: Float = 60.0 / 320.0 {
        didSet {
            selectiveFocusFilter.setFloat(
                excludeCircleRadius,
                forUniformName: "excludeCircleRadius")
        }
    }
    var excludeCirclePoint: CGPoint = CGPoint(
        x: 0.5,
        y: 0.5
    ) {
        didSet {
            selectiveFocusFilter.setPoint(
                excludeCirclePoint,
                forUniformName: "excludeCirclePoint")
        }
    }
    var excludeBlurSize: Float = 30.0 / 320.0 {
        didSet {
            selectiveFocusFilter.setFloat(
                excludeBlurSize,
                forUniformName: "excludeBlurSize")
        }
    }
    var aspectRatio: Float = 0.0 {
        didSet {
            selectiveFocusFilter.setFloat(
                aspectRatio,
                forUniformName: "aspectRatio")
        }
    }
    
    override init() {
        super.init()
        addFilter(blurFilter)
        addFilter(selectiveFocusFilter)
        blurFilter.addTarget(selectiveFocusFilter, atTextureLocation: 1)
        initialFilters = [
            blurFilter,
            selectiveFocusFilter
        ]
        terminalFilter = selectiveFocusFilter
        
        self.blurRadiusInPixels = 5.0;
        self.excludeCircleRadius = 60.0/320.0;
        self.excludeCirclePoint = CGPoint(x:0.5,y:0.5);
        self.excludeBlurSize = 30.0/320.0;
    }
}
