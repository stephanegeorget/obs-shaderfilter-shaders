// This shader was copied and adapted from XorDev
// https://x.com/XorDev
// https://x.com/XorDev/status/1918680610127659112
// https://www.xordev.com/
// Happily vibe-coded with ChatGPT
// [SGEORGET20250523165542]


uniform float _008_Complexity<
  string label = "Complexity (80)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 20;
  float maximum = 150;
  float step = 1;
> = 80;


uniform float _008_DetailFrequency<
  string label = "Detail Frequency (0.5)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.1;
  float maximum = 0.9;
  float step = 0.01;
> = 0.5;




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
    float t = elapsed_time;

    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y); // Y-flipped
    float3 FC = float3(fragCoord, 0.5);
    float3 r = float3(size.x, size.x, size.y); // r.xxy

    float4 o = float4(0, 0, 0, 1);
    float i, z = 0.0, d;

    for (i = 0.; i++ < _008_Complexity;) {
        float3 p = z * normalize(FC * 2.0 - r);
        p.xz -= t;
        p.y = 4.0 - abs(p.y);

        for (d = 0.7; d < 20.0; d /= _008_DetailFrequency) {
            float3 wave = cos(round(p.yzx * d) - 0.2 * t);
            p += wave / d;
        }

        d = 0.01 + abs(p.y) / 15.0;
        z += d;

        float4 wave = cos(float4(0.0, 1.0, 2.0, 0.0) - p.y * 2.0) + 1.1;
        o += wave / z / d;
    }

    o = tanh(o / 700.0);
    o.a = 1.0;
    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
