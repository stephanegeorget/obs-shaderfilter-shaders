// Sea and Vortex
// From Yohei Nishitsuji
// https://x.com/YoheiNishitsuji/status/1931100986220945776
// Sliders added by S. Georget
// [SGEORGET20250607231136]

uniform float _016_Speed<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -2;
  float maximum = 2;
  float step = 0.01;
> = 0.2;



uniform float _016_ParamA<
  string label = "Terrain resolution (12)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 1;
  float maximum = 18;
  float step = 1;
> = 12;



uniform int _016_ParamB<
  string label = "Configuration (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 0;
  int maximum = 5;
  int step = 1;
> = 0;


uniform float _016_ParamC<
  string label = "Shift up/down (1.0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -1;
  float maximum = 2;
  float step = 0.01;
> = 1.0;



uniform float _016_ViewpointHeight<
  string label = "Mountain Height D (3.0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 2.1;
  float maximum = 4;
  float step = 0.01;
> = 3.0;



struct VertData {
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
};

VertData mainTransform(VertData v_in) {
    return v_in;
}

float3 hsv_safe(float h, float s, float v) {
    h = frac(h);
    s = saturate(s);
    v = saturate(v);
    float3 K = float3(1.0, 2.0 / 3.0, 1.0 / 3.0);
    float3 P = abs(frac(h + K) * 6.0 - 3.0);
    float3 rgb = clamp(P - 1.0, 0.0, 1.0);
    return v * lerp(float3(1.0, 1.0, 1.0), rgb, s);
}

float4 mainImage(VertData v_in) : TARGET {
    float2 r = uv_size;
    float2 FC;
    switch(_016_ParamB)
    {
        case 1:
        FC = float2(v_in.uv.y * r.y, (_016_ParamC - v_in.uv.x) * r.x);
        break;

        case 2:
        FC = float2(v_in.uv.x * r.y, (_016_ParamC - v_in.uv.y) * r.x);
        break;

        case 3:
        FC = float2(v_in.uv.x * r.y, (_016_ParamC - v_in.uv.y) * r.y);
        break;
    
        case 4:
        FC = float2(v_in.uv.x * r.x , (_016_ParamC - v_in.uv.y) * (r.y)  )/_016_ParamC;
        break;

        default:
        FC = float2(v_in.uv.x * r.x, (_016_ParamC - v_in.uv.y) * r.y);
        break;
    }

    float t = elapsed_time * _016_Speed;

    float i = 0., e = 0., g = 0., R = 1., s;
    float3 o = float3(0, 0, 0);
    float3 q, p, d = float3((FC * 2.0 - r) / r.x * 0.3 + float2(0, 1), 1);

    q = float3(0, -1, -1);  // Init to match q.zy--
    q.zy -= 1.0;


    for (; i++ < 100.; ) {
        e += i / 9e9;
        o += hsv_safe(0.1, q.y, min(e * i, 0.01));
        s = _016_ViewpointHeight;
        p = q += d * e * R * 0.25;
        g += p.y / s;
        R = (length(p));
        p = float3(log2(R) + t * 0.2, exp2(fmod(-p.z, s) / R) - 0.3, p.x);
        e = p.y - 1.0;
        for (; s < pow(_016_ParamA, 3); s += s) {
            e += -abs(dot(sin(p.xz * s), cos(float2((p.z), p.y) * s)) / s * 0.4);
        }
    }

    return float4(o, 1.0);
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader = mainImage(v_in);
    }
}
