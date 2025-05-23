// This shader was copied and adapted from XorDev
// https://x.com/XorDev
// https://x.com/XorDev/status/1922716290545783182
// https://www.xordev.com/
// Happily vibe-coded with ChatGPT
// I could not keep all the parameters exactly the same as in the original
// shader because my CPU could not handle it, so I tweaked the details threshold.
// [SGEORGET20250523162740]


sampler_state textureSampler {
    Filter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
    BorderColor = 00000000;
};

struct VertData {
    float4 pos : POSITION;
    float2 uv  : TEXCOORD0;
};

VertData mainTransform(VertData v_in) {
    return v_in;
}




uniform float _007_WaveAmplitude<
  string label = "Wave Amplitude (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.0;
  float maximum = 1.2;
  float step = 0.01;
> = 0.2;



uniform float _007_PatternScale<
  string label = "Pattern Scale (0.55)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.45;
  float maximum = 0.9;
  float step = 0.01;
> = 0.55;


uniform float _007_Complexity<
  string label = "Complexity (80)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 10.0;
  float maximum = 150.0;
  float step = 1;
> = 80;


// 🌀 Rotate vector `v` around pseudo-3D axis using screen-based seed
float3 rotate3D(float3 v, float angle, float3 axis) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return v * c + cross(axis, v) * s + axis * dot(axis, v) * oc;
}

float4 mainImage(VertData v_in) : TARGET {
    float2 uv = v_in.uv;
    float2 size = uv_size;
    float t = elapsed_time;

    // 🎯 Match Twigl coordinate expectations
    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y); // Y-flipped
    float3 FC = float3(fragCoord, 0.5);
    float3 r = float3(size.x, size.y, size.y);

    float4 o = float4(0, 0, 0, 1);
    float i, z = 3.0, d;

    // 🧠 Golfed logic preserved
    for(i = 0.; i++ < _007_Complexity; o += 1.9 / d / z){
        float3 p = z * (FC * 2. - r) / r.y, v = p;
        for(d = 1.; d < 2; d /= _007_PatternScale)
            p += _007_WaveAmplitude * sin(p * rotate3D(p, d, r) * d + t) / d;
        z += d = 0.01 + 0.4 * max(d = p.y + p.z * 0.5 + 2.9, -d * 0.5);
    }

    o = tanh(o / float4(9, 6, 3, 1) / 200.0);
    o.a = 1.0;
    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
