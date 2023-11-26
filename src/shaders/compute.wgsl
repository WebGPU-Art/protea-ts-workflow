struct Particle {
  pos: vec3<f32>,
  idx: f32,
  velocity: vec3<f32>,
  _distance: f32,
}

struct Params {
  delta_t: f32,
  height: f32,
  width: f32,
  opacity: f32,
}

struct Particles {
  particles: array<Particle>,
}

@binding(0) @group(0) var<uniform> params: Params;
@binding(1) @group(0) var<storage, read> current_pass: Particles;
@binding(2) @group(0) var<storage, read_write> next_pass: Particles;

struct SphereConstraint {
  center: vec3<f32>,
  radius: f32,
  inside: bool,
}

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) GlobalInvocationID: vec3<u32>) {
  var index = GlobalInvocationID.x;
  let item = current_pass.particles[index];
  let write_target = &next_pass.particles[index];

  let constraints = array<SphereConstraint, 2>(
    SphereConstraint(vec3<f32>(0.0, 0.0, 0.0), 100.0, true),
    // SphereConstraint(vec3<f32>(0.0, 100.0, 0.0), 180.0, true),
    SphereConstraint(vec3<f32>(0.0, -150.0, 0.0), 20.0, false)
  );

  var v_pos = item.pos;

  let velocity = item.velocity;
  let next_pos = item.pos + velocity * params.delta_t;

  // some logic to change position and velocity
  for (var i = 0u; i < 2u; i = i + 1u) {
    let constraint = constraints[i];
    let center = constraint.center;
    let radius = constraint.radius;
    let inside = constraint.inside;

    let next_base = next_pos - center;
    let next_distance = length(next_base);
    let direction = normalize(next_base);

    if inside {
      if length(next_distance) >= radius {
        let change_velocity = dot(direction, velocity) * direction;
        let next_velocity = velocity - 2.0 * change_velocity;
        (*write_target).velocity = next_velocity;
        (*write_target).pos = v_pos + next_velocity * params.delta_t;
        return;
      }
    } else {
      if length(next_distance) <= radius {
        let change_velocity = dot(direction, velocity) * direction;
        let next_velocity = velocity - 2.0 * change_velocity;
        (*write_target).velocity = next_velocity;
        (*write_target).pos = v_pos + next_velocity * params.delta_t;
        return;
      }
    }
  }


  // default movement
  (*write_target).pos = next_pos;
  (*write_target).velocity = velocity;
}