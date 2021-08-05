//
//  relu6.metal
//  metal-sample
//
//  Created by zhangjun31 on 2021/8/5.
//

#include <metal_stdlib>
using namespace metal;

struct Relu6Params {
  float a;
};

kernel void relu6(
  texture2d_array<half, access::read> inTexture [[texture(0)]],
  texture2d_array<half, access::write> outTexture [[texture(1)]],
  constant Relu6Params& params [[buffer(0)]],
  uint3 gid [[thread_position_in_grid]])
{
  if (gid.x >= outTexture.get_width() ||
      gid.y >= outTexture.get_height() ||
      gid.z >= outTexture.get_array_size()) return;

  const half4 i = inTexture.read(gid.xy, gid.z);
  const half4 o = fmin(fmax(i, 0.0h) + params.a*fmin(i, 0.0h), 6.0h);
  outTexture.write(o, gid.xy, gid.z);
}
@zhangjun

