//
//  ViewController.m
//  metal-sample
//
//  Created by zhangjun31 on 2021/8/4.
//

#import "ViewController.h"
#import <Metal/Metal.h>
#include <string>

@interface ViewController ()
@property (nonatomic, weak) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLFunction> computeFunction;
@property (nonatomic, strong) id<MTLLibrary> library;
@property (nonatomic, strong) id<MTLBuffer> inputBuffer;
@property (nonatomic, strong) id<MTLCommandQueue> queue;
@property (nonatomic, strong) MTLComputePipelineDescriptor *computePipelineDescriptor;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    MTLResourceOptions resourceOptions = 0;
    const float triangleData[] = {
            0.0, 1.0, 0.0,
            -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0
    };
    _inputBuffer = [_device newBufferWithBytes:triangleData length:sizeof(triangleData) options:resourceOptions];
    _computeFunction = [_library newFunctionWithName:@"compute"];
    
    id <MTLDevice> device = MTLCreateSystemDefaultDevice();
    id <MTLCommandQueue> commandQueue = [device newCommandQueue];
    
    id <MTLRenderPipelineState> pipelineState;

    id <MTLLibrary> defaultLibrary   = [device newDefaultLibrary];
    id <MTLFunction> fragmentProgram = [defaultLibrary newFunctionWithName:@"basic_fragment"];
    id <MTLFunction> vertexProgram   = [defaultLibrary newFunctionWithName:@"basic_vertex"];

    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction   = vertexProgram;
    pipelineStateDescriptor.fragmentFunction = fragmentProgram;
    [pipelineStateDescriptor.colorAttachments objectAtIndexedSubscript:0].pixelFormat = MTLPixelFormatBGRA8Unorm;

    NSError *pipelineError = nil;
    pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&pipelineError];

    if (!pipelineState) {
        NSLog(@"Failed to create pipeline state, error %@", pipelineError);
    }
    
    id <MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

    if (renderEncoder) {
        [renderEncoder setRenderPipelineState:self.pipelineState];
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3 instanceCount:1];
        [renderEncoder endEncoding];
    }
    [commandBuffer commit];
    // https://gist.github.com/suzumura-ss/79150309af32bf151435acbdff920cfc
}

- (IBAction)Run:(id)sender {
    std::string result = "metal sample";
    NSString *data = [NSString stringWithFormat:@"%s", result.c_str()];
    NSLog(@"%@", data);
    self.ResultArea.text = data;
}

@end
