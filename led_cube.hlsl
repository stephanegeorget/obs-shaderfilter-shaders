// This shader was copied and adapted from XorDev
// Twitter account: https://x.com/XorDev
// Exact Tweet: https://x.com/XorDev/status/1922025965275824484
// See also: https://www.xordev.com/
// Happily vibe-coded with ChatGPT - [SGEORGET20250523143035]


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


// 🌐 User-defined controls
uniform float _002_offsetX<
  string label = "Offset X (0)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = -1000;
  float maximum = 1000;
  float step = 1;
> = 0;

uniform float _002_offsetY<
  string label = "Offset X (0)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = -1000;
  float maximum = 1000;
  float step = 1;
> = 0;


uniform float _002_cubesize<
  string label = "Cube Size X (3)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = 1;
  float maximum = 5;
  float step = 1;
> = 3;


uniform float _002_zoom<
  string label = "Zoom (1)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = 0.01;
  float maximum = 3;
  float step = 0.01;
> = 1;


uniform float _002_timeScale<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = 0.01;
  float maximum = 3;
  float step = 0.01;
> = 0.2;





// 🌀 mat2 emulation (non-orthogonal shimmer)
float2 matRow(float t, float shiftA, float shiftB) {
    return float2(cos(t / 4.0 + shiftA), cos(t / 4.0 + shiftB));
}

float4 mainImage(VertData v_in) : TARGET {
    

// 🌀 Uniforms for user control
    float offsetX = _002_offsetX;
    float offsetY = _002_offsetY;
    float zoom = _002_zoom;
    float timeScale = _002_timeScale;
    float cubesize = _002_cubesize;

    float2 uv = v_in.uv;
    float2 size = uv_size;
    float t = elapsed_time * timeScale;

    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y);
    float3 FC = float3(fragCoord, 0.5);
    float3 r = float3(size.x, size.y, size.y);

    // ✅ Centered zoom and scaled pan
    float2 center = 0.5 * size;
    float2 panOffset = float2(offsetX, offsetY) * 10.0;
    float2 shifted = (FC.xy - center + panOffset) * zoom + center;
    FC = float3(shifted, FC.z);

    float4 o = float4(0, 0, 0, 1);
    float i, z = 0.0, d;

    // Shader computation
    for (i = 0.; i++ < 50.;) {
        float3 p = z * normalize(FC * 2.0 - float3(r.x, r.y, r.y));
        p.z += 8.0;

        float2 mrow0 = matRow(t, 0.0, 33.0);
        float2 mrow1 = matRow(t, 11.0, 0.0);
        p.xz = float2(dot(mrow0, p.xz), dot(mrow1, p.xz));

        d = max(
            length(cos(p / 0.2)) / 8.0,
            length(clamp(p, -cubesize, cubesize) - p)
        );
        z += d;

        float4 wave = cos(dot(cos(p), sin(p / 0.6).yzx) + t + float4(0, 1, 2, 3)) + 1.1;
        o += wave / d / z;
    }

    o = tanh(o / 70.0);
    o.a = 1.0;
    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
