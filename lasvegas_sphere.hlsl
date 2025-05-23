// This shader was copied and adapted from XorDev
// Twitter account: https://x.com/XorDev
// Exact Tweet: https://x.com/XorDev/status/1922291638279270581
// See also: https://www.xordev.com/
// Happily vibe-coded with ChatGPT - [SGEORGET20250523141631]

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

// 🌐 User-defined controls
uniform float _001_offsetX<
  string label = "Offset X (0)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = -1000;
  float maximum = 1000;
  float step = 1;
> = 0;

uniform float _001_offsetY<
  string label = "Offset Y (0)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = -1000;
  float maximum = 1000;
  float step = 1;
> = 0;

uniform float _001_zoom<
  string label = "Zoom (0.3)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = 0.1;
  float maximum = 3;
  float step = 0.1;
> = 0.3;


uniform float _001_timeScale<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Group";
  float minimum = 0.01;
  float maximum = 2;
  float step = 0.01;
> = 0.2;


// 🔄 Fake mat2 for rotation
float2 rot2(float2 p, float a) {
    float s = sin(a);
    float c = cos(a);
    return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

float4 mainImage(VertData v_in) : TARGET {
    
    float offsetX = _001_offsetX;
    float offsetY = _001_offsetY;
    float zoom = _001_zoom;
    float timeScale = _001_timeScale;

    float2 uv = v_in.uv;
    float2 size = uv_size;
    float t = elapsed_time * timeScale * 0.1;

    // 🧭 Setup coordinates (centered zoom + pan + Y flip)
    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y);
    float3 FC = float3(fragCoord, 0.5);
    float3 r = float3(size.x, size.y, size.y);

    float2 center = 0.5 * size;
    float2 panOffset = float2(offsetX, offsetY) * 10.0;
    float2 shifted = (FC.xy - center + panOffset) * zoom + center;
    FC = float3(shifted, FC.z);

    // 🧠 Golfed logic preserved
    float4 o = float4(0, 0, 0, 1);
    float i, z, d;

    for(i = 0.; i++ < 100.;
        o += (cos(z + t + float4(0, 1, 5, 0)) + 1.2) / d / z
    ) {
        float3 v, p = z * normalize(FC * 2.0 - r);
        p.z += 9.0;
        p.xz = rot2(p.xz, 0.2 * t); // replaces mat2(...)
        v = p;
        z += d = 0.2 * (
            0.01 +
            abs(dot(cos(p), cos(p / 0.6).yzx)) -
            min(d = 5.0 + cos(t) - length(p), -d * 0.2)
        );
    }

    o = tanh(o / 400.0);
    o.a = 1.0;
    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
