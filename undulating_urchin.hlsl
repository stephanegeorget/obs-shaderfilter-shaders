// Undulating Urchin
// From ChunderFPV
// https://www.shadertoy.com/view/332XWd
// https://perspectiveinfinity.epizy.com/	
// [SGEORGET20250608173449]


uniform float _018_Speed< 
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 2;
  float step = 0.01;
> = 0.2;


uniform float _018_Curl< 
  string label = "Curl (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 2;
  float step = 0.01;
> = 0.2;



uniform int _018_Iterations< 
  string label = "Iterations (70)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 1;
  int maximum = 80;
  int step = 1;
> = 70;




float3 H(float a) {
    return cos(radians(float3(180, 90, 0)) + a * 6.2832) * 0.5 + 0.5;
}

float map(float3 u, float v, float t) {
    float l = 5.0;
    float f = 1e10, i = 0.0, y, z;

    u.xy = float2(atan2(u.x, u.y), length(u.xy));
    u.x += t * v * 3.1416 * 0.7;

    for (; i++ < l;) {
        float3 p = u;
        y = round((p.y - i) / l) * l + i;
        p.x *= y;
        p.x -= y * y * t * 3.1416;
        p.x -= round(p.x / 6.2832) * 6.2832;
        p.y -= y;
        z = cos(y * t * 6.2832) * 0.5 + 0.5;
        f = min(f, max(length(p.xy), -p.z - z * 9.0) - 0.1 - z * 0.2 - p.z / 1e2);
    }
    return f;
}

float4 mainImage(VertData v_in) : TARGET {
    float2 mouse = float2(0.0, 0.0);
float4 mouse_raw = float4(0.0, 0.0, 0.0, 0.0);

    float2 fragCoord = v_in.uv * uv_size;
    float2 R = uv_size;
    float t = elapsed_time / 300.0 * _018_Speed;

    float2 m = (mouse.xy - R / 2.0) / R.y;
    if (mouse_raw.z < 1.0 && mouse.x + mouse.y < 10.0) {
        m = float2(0.0, 0.5);
    }

    float3 o = float3(0.0, 0.0, -130.0);
    float3 u = normalize(float3(fragCoord - R / 2.0, R.y));
    float3 c = float3(0.0, 0.0, 0.0);
    float3 p, k;

    float v = -o.z / 3.0;
    float i = 0.0, d = 0.0;
    float s, f, z, r;
    bool b;

    for (; i++ < _018_Iterations;) {
        p = u * d + o;
        p.xy /= v;
        r = length(p.xy);
        z = abs(1.0 - r * r);
        b = r < 1.0;
        if (b) z = sqrt(z);
        p.xy /= z + 1.0;
        p.xy -= m;
        p.xy *= v;
        p.xy -= cos(p.z / 8.0 + t * 300.0 + float2(0, 1.5708) + z / 2.0) * _018_Curl;

        s = map(p, v, t);

        r = length(p.xy);
        f = cos(round(r) * t * 6.2832) * 0.5 + 0.5;
        k = H(0.2 - f / 3.0 + t + p.z / 200.0);
        if (b) k = 1.0 - k;

        c += min(exp(s / -0.05), s)
           * (f + 0.01)
           * min(z, 1.0)
           * sqrt(cos(r * 6.2832) * 0.5 + 0.5)
           * k * k;

        if (s < 1e-3 || d > 1e3) break;
        d += s * clamp(z, 0.2, 0.9);
    }

    // Removed texture-based aqua glow to avoid invalid sampler error
    // float3 tex = tex2D(image, u.xy * d + o.xy).rrr;
    // c += tex * float3(0, 0.4, s) * s * z * 0.03;

    c += min(exp(-p.z - f * 9.0) * z * k * 0.01 / s, 1.0);

    float2 j = p.xy / v + m;
    c /= clamp(dot(j, j) * 4.0, 0.04, 4.0);

    c = saturate(c);
    return float4(pow(c, 1.0 / 2.2), 1.0);
}

struct VertData {
    float4 pos : POSITION;
    float2 uv  : TEXCOORD0;
};

VertData mainTransform(VertData v_in) {
    return v_in;
}



technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
