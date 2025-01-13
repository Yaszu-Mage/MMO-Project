shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
// Based on https://www.shadertoy.com/view/ldl3W8
// The MIT License
// Copyright © 2013 Inigo Quilez
vec3 iq_voronoi(vec2 x, vec2 size, vec2 stretch, float randomness, vec2 seed) {
	vec2 n = floor(x);
	vec2 f = fract(x);
	vec2 mg, mr, mc;
	float md = 8.0;
	for (int j=-1; j<=1; j++)
	for (int i=-1; i<=1; i++) {
		vec2 g = vec2(float(i),float(j));
		vec2 o = randomness*rand2(seed + mod(n + g + size, size));
		vec2 c = g + o;
		vec2 r = c - f;
		vec2 rr = r*stretch;
		float d = dot(rr,rr);
		if (d<md) {
			mc = c;
			md = d;
			mr = r;
			mg = g;
		}
	}
	md = 8.0;
	for (int j=-2; j<=2; j++)
	for (int i=-2; i<=2; i++) {
		vec2 g = mg + vec2(float(i),float(j));
		vec2 o = randomness*rand2(seed + mod(n + g + size, size));
		vec2 r = g + o - f;
		vec2 rr = (mr-r)*stretch;
		if (dot(rr,rr)>0.00001)
	   		md = min(md, dot(0.5*(mr+r)*stretch, normalize((r-mr)*stretch)));
	}
	return vec3(md, mc+n);
}
vec4 voronoi(vec2 uv, vec2 size, vec2 stretch, float intensity, float randomness, float seed) {
	uv *= size;
	vec3 v = iq_voronoi(uv, size, stretch, randomness, rand2(vec2(seed, 1.0-seed)));
	return vec4(v.yz, intensity*length((uv-v.yz)*stretch), v.x);
}
vec2 rotate(vec2 uv, float rotate) {
 	vec2 rv;
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	return rv;	
}
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
const vec4 p_o12772_albedo_color = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o12772_metallic = 0.000000000;
const float p_o12772_roughness = 1.000000000;
const float p_o12772_emission_energy = 1.000000000;
const float p_o12772_normal = 1.000000000;
const float p_o12772_ao = 1.000000000;
const float p_o12772_depth_scale = 0.500000000;
float o12772_input_depth_tex(vec2 uv, float _seed_variation_) {
return 0.0;
}
const float p_o92964_center = 0.000000000;
const float p_o12795_gradient_0_pos = 0.000000000;
const vec4 p_o12795_gradient_0_col = vec4(1.000000000, 0.058593750, 0.058593750, 1.000000000);
const float p_o12795_gradient_1_pos = 0.275753366;
const vec4 p_o12795_gradient_1_col = vec4(1.000000000, 0.058593750, 0.058593750, 1.000000000);
const float p_o12795_gradient_2_pos = 0.275773366;
const vec4 p_o12795_gradient_2_col = vec4(1.000000000, 0.613769531, 0.117187500, 1.000000000);
const float p_o12795_gradient_3_pos = 0.447509100;
const vec4 p_o12795_gradient_3_col = vec4(1.000000000, 0.613769531, 0.117187500, 1.000000000);
const float p_o12795_gradient_4_pos = 0.447529100;
const vec4 p_o12795_gradient_4_col = vec4(1.000000000, 0.960937500, 0.000000000, 1.000000000);
const float p_o12795_gradient_5_pos = 0.733768606;
const vec4 p_o12795_gradient_5_col = vec4(1.000000000, 0.960937500, 0.000000000, 1.000000000);
const float p_o12795_gradient_6_pos = 0.733788606;
const vec4 p_o12795_gradient_6_col = vec4(1.000000000, 0.562500000, 0.000000000, 1.000000000);
vec4 o12795_gradient_gradient_fct(float x) {
  if (x < 0.5*(p_o12795_gradient_0_pos+p_o12795_gradient_1_pos)) {
    return p_o12795_gradient_0_col;
  } else if (x < 0.5*(p_o12795_gradient_1_pos+p_o12795_gradient_2_pos)) {
    return p_o12795_gradient_1_col;
  } else if (x < 0.5*(p_o12795_gradient_2_pos+p_o12795_gradient_3_pos)) {
    return p_o12795_gradient_2_col;
  } else if (x < 0.5*(p_o12795_gradient_3_pos+p_o12795_gradient_4_pos)) {
    return p_o12795_gradient_3_col;
  } else if (x < 0.5*(p_o12795_gradient_4_pos+p_o12795_gradient_5_pos)) {
    return p_o12795_gradient_4_col;
  } else if (x < 0.5*(p_o12795_gradient_5_pos+p_o12795_gradient_6_pos)) {
    return p_o12795_gradient_5_col;
  }
  return p_o12795_gradient_6_col;
}
const float p_o12794_x = 16.000000000;
const float p_o12794_y = 16.000000000;
const float p_o12794_c = 8.000000000;
const float p_o12794_d = 0.500000000;
const float p_o12790_translate_x = 0.000000000;
const float p_o12774_amount1 = 0.500000000;
const float seed_o12773 = 0.000000000;
const float p_o12773_scale_x = 4.000000000;
const float p_o12773_scale_y = 4.000000000;
const float p_o12773_stretch_x = 1.000000000;
const float p_o12773_stretch_y = 1.000000000;
const float p_o12773_intensity = 1.000000000;
const float p_o12773_randomness = 1.000000000;
const float p_o12789_cx = 0.000000000;
const float p_o12789_cy = 0.000000000;
const float p_o12789_rotate = -90.000000000;
const float p_o12775_gradient_0_pos = 0.000000000;
const vec4 p_o12775_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o12775_gradient_1_pos = 0.483507130;
const vec4 p_o12775_gradient_1_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o12775_gradient_2_pos = 0.483527130;
const vec4 p_o12775_gradient_2_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o12775_gradient_gradient_fct(float x) {
  if (x < 0.5*(p_o12775_gradient_0_pos+p_o12775_gradient_1_pos)) {
    return p_o12775_gradient_0_col;
  } else if (x < 0.5*(p_o12775_gradient_1_pos+p_o12775_gradient_2_pos)) {
    return p_o12775_gradient_1_col;
  }
  return p_o12775_gradient_2_col;
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec2 o12794_0_uv = floor((((uv)+(cos(elapsed_time))*((uv).yx-vec2(p_o92964_center))*vec2(1.0, 0.0))*vec2(p_o12794_x, p_o12794_y)))+vec2(0.5);
vec3 o12794_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o12794_0_uv))/vec3(103.0, 71.0, 97.0));
vec4 o12773_0_xyzw = voronoi(((o12794_0_uv/vec2(p_o12794_x, p_o12794_y))-vec2(p_o12790_translate_x, (-elapsed_time))), vec2(p_o12773_scale_x, p_o12773_scale_y), vec2(p_o12773_stretch_y, p_o12773_stretch_x), p_o12773_intensity, p_o12773_randomness, (seed_o12773+fract(_seed_variation_)));float o12773_0_1_f = o12773_0_xyzw.z;
vec2 o12789_0_c = vec2(0.5+p_o12789_cx, 0.5+p_o12789_cy);vec4 o12775_0_1_rgba = o12775_gradient_gradient_fct(((rotate(((o12794_0_uv/vec2(p_o12794_x, p_o12794_y))-vec2(p_o12790_translate_x, (-elapsed_time)))-o12789_0_c, p_o12789_rotate*0.01745329251)+o12789_0_c)).x);
vec4 o12789_0_1_rgba = o12775_0_1_rgba;
vec4 o12774_0_b = vec4(vec3(o12773_0_1_f), 1.0);
vec4 o12774_0_l;
float o12774_0_a;

o12774_0_l = o12789_0_1_rgba;
o12774_0_a = p_o12774_amount1*1.0;
o12774_0_b = vec4(blend_additive(((o12794_0_uv/vec2(p_o12794_x, p_o12794_y))-vec2(p_o12790_translate_x, (-elapsed_time))), o12774_0_l.rgb, o12774_0_b.rgb, o12774_0_a*o12774_0_l.a), min(1.0, o12774_0_b.a+o12774_0_a*o12774_0_l.a));

vec4 o12774_0_2_rgba = o12774_0_b;
vec4 o12790_0_1_rgba = o12774_0_2_rgba;
vec3 o12794_0_1_rgb = floor(((o12790_0_1_rgba).rgb)*p_o12794_c+p_o12794_d*(o12794_0_dither-vec3(0.5)))/p_o12794_c;
vec4 o12795_0_1_rgba = o12795_gradient_gradient_fct((dot(o12794_0_1_rgb, vec3(1.0))/3.0));
vec4 o92964_0_1_rgba = o12795_0_1_rgba;

	vec3 albedo_tex = ((o92964_0_1_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o12772_albedo_color.rgb;
	METALLIC = 1.0*p_o12772_metallic;
	ROUGHNESS = 1.0*p_o12772_roughness;
	NORMAL = vec3(0.5);
	EMISSION = vec3(0.0)*p_o12772_emission_energy;

}



