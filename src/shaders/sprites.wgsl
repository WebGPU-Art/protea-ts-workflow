
#import protea::perspective
#import protea::colors

struct Params {
  delta_t: f32,
  length: f32,
  width: f32,
  opacity: f32,
}

@group(1) @binding(0) var<uniform> params: Params;

struct VertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(1) color: vec4<f32>,
}

@vertex
fn vert_main(
  @location(0) position: vec3<f32>,
  @location(1) point_idx: f32,
  @location(2) velocity: vec3<f32>,
  @location(3) _travel: f32,
  @location(5) idx: u32,
) -> VertexOutput {
  let right = normalize(uniforms.rightward);
  let up = normalize(uniforms.upward);
  let width = params.width * 1.4;
  let scale: f32 = 0.02;

  // vertex of rectangle encoded in idx
  let pos: vec3<f32> = position + right * width * f32(idx % 2u) + up * width * floor(f32(idx) / 2.0);
  let color: vec3<f32> = hsl(fract(point_idx / 1000000.), 0.8, max(0.1, 0.9 - 0.2));

  var output: VertexOutput;
  // position after perspective transform
  output.position = vec4(transform_perspective(pos).point_position * scale, 1.0);
  output.color = vec4(color, params.opacity);
  return output;
}

@fragment
fn frag_main(@location(1) color: vec4<f32>) -> @location(0) vec4<f32> {
  return color;
}
