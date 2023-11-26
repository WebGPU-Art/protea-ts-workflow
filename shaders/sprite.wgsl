#import protea::perspective
#import protea::colors

struct SimParams {
  delta_t: f32,
  length: f32,
  width: f32,
  opacity: f32,
}

@group(1) @binding(0) var<uniform> params: SimParams;


struct VertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(4) color: vec4<f32>,
}

@vertex
fn vert_main(
  @location(0) position: vec3<f32>,
  @location(1) ages: f32,
  @location(2) prev_pos: vec3<f32>,
  @location(3) travel: f32,
  @location(4) _v: vec3<f32>,
  @location(5) _p: f32,
  @location(6) idx: u32,
) -> VertexOutput {
  var pos: vec3<f32>;
  let v0 = position - prev_pos;
  var prev_position = prev_pos;
  let right = normalize(cross(v0, uniforms.forward));

  // let front = params.length;
  var width = params.width * 0.8;

  if ages < 0.04 {
    // prev_position = position;
    width = 0.0;
  }
  // TODO hack
  if distance(position, prev_pos) > 1000.0 {
    width = 0.0;
  }

  if idx == 0u {
    pos = position + right * width;
    // pos += vec3(1.,1.,1.) * 100.0;
  } else if idx == 1u {
    pos = position - right * width;
  } else if idx == 2u {
    pos = prev_position + right * width;
  } else if idx == 3u {
    pos = prev_position - right * width;
  } else {
    pos = position;
  }

  var output: VertexOutput;
  let p0 = vec4(pos * 10.0, 1.0);

  let p = transform_perspective(p0.xyz).point_position;
  let scale: f32 = 0.002;

  output.position = vec4(p[0] * scale, p[1] * scale, p[2] * scale, 1.0);
  let c3: vec3<f32> = hsl(fract(travel / 100000.), 0.97, max(0.9, 0.7 - ages * 0.02));
  output.color = vec4(c3, max(0.04, 1. - ages * 0.3));
  return output;
}

@fragment
fn frag_main(@location(4) color: vec4<f32>) -> @location(0) vec4<f32> {
  return color;
  // return vec4<f32>(1., 0., 0., 1.0);
}