// rotating maze
// From XorDev
// https://x.com/XorDev/status/1534951614271868929
// [SGEORGET20250526150032]

uniform float _015_Speed<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.05;
  float maximum = 2;
  float step = 0.01;
> = 0.2;


uniform float _015_ParamA<
  string label = "Parameter A (0.3)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.1;
  float maximum = 0.6;
  float step = 0.01;
> = 0.3;


uniform float _015_ParamB<
  string label = "Parameter B (60)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 200;
  float step = 1;
> = 60;


uniform float _015_ParamC<
  string label = "Parameter C (0.5)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 1;
  float step = 0.01;
> = 0.5;

uniform float _015_Shadow<
  string label = "Shadow (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 0.5;
  float step = 0.01;
> = 0;





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

float fsnoise(float2 p) {
    return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

float4 mainImage(VertData v_in) : TARGET {
    float2 r = uv_size;
    float t = elapsed_time * _015_Speed;
    float2 FC = float2(v_in.uv.x * r.x, (1.0 - v_in.uv.y) * r.y); // Y-flipped

    float4 o = 0;
    for (float y = 0.0; y++ < 100.0;) {
        float2 i = float2(0.0, y);
        float2 z, p = (FC - i - 0.5 * r) / r.y * float2(1.0, 2.0);
        z = p;
        z.x += 1.0;
        p.x -= 0.5;
        float l2 = dot(p, p);
        float2 rot = float2(z.x, -z.y);
        float2 pRot = float2(
            (p.x * rot.x - p.y * rot.y),
            (p.x * rot.y + p.y * rot.x)
        ) / l2;
        p = pRot;
        p += 0.5;

        float len = length(p);
        p = log(len) * float2(5.0, -5.0) + atan2(p.y, p.x) / 3.1415926535 * 10.0 + t;

        float2 ceilp = ceil(p);
        float noise = fsnoise(fmod(ceilp, 10.0));
        float s = sign(noise - _015_ParamC);
        float v = abs(frac(p.x + p.y * s) - 0.5);
        float l = length(ddx(p) + ddy(p)) * r.y *( _015_ParamC -0.3);

        if (v > _015_ParamA && (_015_ParamB - y) > l) {
            float factor = (y * y / 10000.0);
            if (_015_Shadow != 0)
            {
                float3 rgb = lerp(float3(0.1, 0.1, 0.1), float3(0.8, 0.8, 0.8), frac(t * 0.1 - p.x * _015_Shadow));
                o.rgb += (1.0 - o.rgb) * factor * 1 * rgb;
            }
            else
            {
                o.rgb += (1.0 - o.rgb) * factor * 1;
            }
        }
    }

    return float4(o.rgb, 1.0);

}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader = mainImage(v_in);
    }
}
