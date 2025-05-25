// fractal 1
// Inspired from Yohei Nishitsuji
// https://x.com/YoheiNishitsuji/status/1923362809569837131
// Then happily vibe-coded with ChatGPT
// [SGEORGET20250526001345]



uniform float _014_Speed<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.05;
  float maximum = 2;
  float step = 0.01;
> = 0.2;


uniform float _014_ParamA<
  string label = "Integration loop (87)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 10;
  float maximum = 120;
  float step = 1;
> = 87;

uniform float _014_ParamB<
  string label = "Fractal fold (13)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 1;
  float maximum = 34;
  float step = 1;
> = 13;

uniform float _014_ParamC<
  string label = "Offset (7)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -22;
  float maximum = 22;
  float step = 0.1;
> = 7;



uniform float _014_Roll<
  string label = "Roll (0.6)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -22;
  float maximum = 22;
  float step = 0.1;
> = 0.6;

uniform float _014_ParamD<
  string label = "Fractal seed (3.92)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 3.7;
  float maximum = 4.2;
  float step = 0.01;
> = 3.92;


uniform float _014_Zoom<
  string label = "Zoom (3.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -1;
  float maximum = 10;
  float step = 0.1;
> = 3.2;

uniform float _014_Brightness<
  string label = "Brightness (540)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 10;
  float maximum = 2000;
  float step = 1;
> = 540;

uniform float _014_Saturation<
  string label = "Saturation (0.5)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 1;
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

float2 rotate2D(float a, float2 p) {
    float s = sin(a), c = cos(a);
    return float2(p.x * c - p.y * s, p.x * s + p.y * c);
}





float3x3 rotate3D(float a, float3 axis) {
    axis = normalize(axis);
    float c = cos(a), s = sin(a), ic = 1.0 - c;
    return float3x3(
        c + axis.x * axis.x * ic,       axis.x * axis.y * ic - axis.z * s, axis.x * axis.z * ic + axis.y * s,
        axis.y * axis.x * ic + axis.z * s, c + axis.y * axis.y * ic,       axis.y * axis.z * ic - axis.x * s,
        axis.z * axis.x * ic - axis.y * s, axis.z * axis.y * ic + axis.x * s, c + axis.z * axis.z * ic
    );
}

float3 hsv(float h, float s, float v) {
    float3 rgb = clamp(abs(frac(h + float3(0., 2. / 3., 1. / 3.)) * 6. - 3.) - 1., 0., 1.);
    return lerp(float3(1., 1., 1.), rgb, s) * v;
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 r = uv_size;
    float t = elapsed_time * _014_Speed;
    
    // Flip Y axis to match GLSL behavior
    float2 FC = float2(v_in.uv.x * r.x, (1.0 - v_in.uv.y) * r.y);
    float2 normPos = (FC.xy - 0.5 * r) / r.y * _014_Zoom; // Zoom factor

    float4 o = 0;

    for (float i = 0., g = -0.0, e=0, s=0; ++i < _014_ParamA;)
    {
        float3 p = float3(normPos, g - _014_ParamC);

        // Per-fragment 3D rotation around axis (0,9,-3)
        float3x3 R = rotate3D(3.0, float3(0.0, _014_Roll, -3.0));
        p = mul(R, p);

        p.xz = rotate2D(t * 0.3, p.xz);


        s = 6.0;
        e = 1.0;  // Reset e every ray step

        for (int j = 0; j++ < _014_ParamB;) {
            p = float3(0.0, _014_ParamD, -1.0) - abs(abs(p) * e - float3(3.0, 4.0, 3.0));
            float d = dot(p, p * 0.47);
            e = 7.5 / d;
            s *= e;
        }

        g += p.y * p.y / s * 0.3;
        s = log2(s) - g * 0.8;
        float brightness = saturate(s / _014_Brightness);
        float hue = fmod(0.1 + i * 0.02 + t * 0.3, 1.0);
        o.rgb += saturate(hsv(hue, _014_Saturation, brightness)) * 0.7;
    }

    return float4(o.rgb, 1.0);
}

technique Draw
{
    pass
    {
        vertex_shader = mainTransform(v_in);
        pixel_shader = mainImage(v_in);
    }
}
