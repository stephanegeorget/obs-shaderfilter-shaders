// This shader was copied and adapted from XorDev
// Twitter account: https://x.com/XorDev
// Exact Tweet: https://x.com/XorDev/status/1923048330059227477
// See also: https://www.xordev.com/
// I tried hard but could not make it string-like as on Twigl
// So I tweaked the gamma and added a few parameters.
// [SGEORGET20250523140432]


uniform float _003_luminosity<
  string label = "Luminosity Adjustment (1.8)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = 0.0;
  float maximum = 10.0;
  float step = 0.01;
> = 1.80;


uniform float _003_speed<
  string label = "Speed Adjustment (0.2)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = 0.0;
  float maximum = 3.0;
  float step = 0.01;
> = 0.2;


uniform int _003_iterations<
  string label = "Iterations Adjustment (100)";
  string widget_type = "slider";
  string group = "Group";
  int minimum = 2;
  int maximum = 200;
  int step = 1;
> = 100;


sampler_state textureSampler {
    Filter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct VertData {
    float4 pos : POSITION;
    float2 uv  : TEXCOORD0;
};

VertData mainTransform(VertData v_in) {
    return v_in;
}

float4 mainImage(VertData v_in) : TARGET {
    float2 uv = v_in.uv;
    float2 size = uv_size;
    float t = elapsed_time * _003_speed;

    // Fragment coordinates (Y-flipped)
    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y);
    float3 FC = float3(fragCoord, 0.5);
    float3 r = float3(size.x, size.y, size.y);

    float4 o = float4(0.0, 0.0, 0.0, 1.0);
    float z = 3.0;
    float d = 0.0;

    for (float i = 0.0; i < _003_iterations; i++) {
        float3 p = z * normalize(r - FC * 2.0) - 1.0;

        d = max(p.y, 0.0);
        p.y -= d + d;
        p.z += t;

        d += 1.0;
        float lenPart = length(float2(
            cos(p.z * 6.0) / 6.0,
            1.0 - dot(cos(p), sin(p).yzx)
        )) / (d * d);

        d = 0.3 * (0.1 * d + 0.01 + lenPart);
        z += d;

        float4 wave = cos(p.z + float4(0.0, 1.0, 3.0, 0.0)) + 1.2;

        // 🔥 Sharpen line presence using exponential falloff
        float envelope = exp(-80.0 * d); // tweak exponent as needed
        float4 term = wave * envelope / (d * z);

        o += term;
    }

    o = tanh(o / 1.0 * _003_luminosity);
    o.a = 1.0;
    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
