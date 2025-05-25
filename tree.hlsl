


uniform float _013_Speed<
  string label = "Speed (0.44)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 2;
  float step = 0.01;
> = 0.44;


uniform float _013_CameraX<
  string label = "Camera X (-0.01)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -2;
  float maximum = 2;
  float step = 0.01;
> = -0.01;



uniform float _013_CameraY<
  string label = "Camera Y (1.30)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -2;
  float maximum = 2;
  float step = 0.01;
> = 1.30;



uniform float _013_CameraZ<
  string label = "Camera Z (-1.42)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -2;
  float maximum = 2;
  float step = 0.01;
> = -1.42;


uniform float _013_ParamA<
  string label = "Parameter A (0.02)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -2;
  float maximum = 2;
  float step = 0.01;
> = 0.02;


uniform float _013_ParamB<
  string label = "Parameter B (1.85)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -2;
  float maximum = 3;
  float step = 0.01;
> = 1.85;



uniform float _013_ParamC<
  string label = "Parameter C (0.03)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -2;
  float maximum = 3;
  float step = 0.01;
> = 0.03;

uniform float _013_ParamD<
  string label = "Parameter D (0.0015)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 0.1;
  float step = 0.0005;
> = 0.0015;


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

float4 mainImage(VertData v_in) : TARGET {
    float2 r = uv_size;
    float t = elapsed_time * _013_Speed;
    float2 FC = float2(v_in.uv.x * r.x, v_in.uv.y * r.y); // no Y flip


    float4 o = 0;

    float3 p, q = float3(_013_CameraX, _013_CameraY, _013_CameraZ);

    float j, i = 0., e = 1e-5, v = 1.0, u = 1.0;  // init to safe defaults

    for (; i++ < 110.;i=i+1) {
        p = q += float3((FC - 0.5 * r) / r.y, 1.0) * e;

        j = 7;
        e = 9;
        v = 7;

        for (; j++ < 20.;) {
            float a = j + sin(1.0 / u + t) / v;
            p.xz = abs(rotate2D(a, p.xz)) - 0.45;
            float d = length(p.xz) - 0.02 / u;
            p.y = _013_ParamB - p.y;
            e = min(e, max(d, p.y) / (v));
            u = max(dot(p, p), 0.001);  // prevent zero
            v /= u + _013_ParamC;
            p /= (u + _013_ParamA);
        }

        float4 term = v * float4(9, 500, 4, 4) + e * 2e5;
        //o += 0.007/ exp(30000.0 / term - 0.01);
        //term = max(term,0.001);
        //term = min(term,-0.001);
        //o += term;
        o += 0.017/ exp(3000.0 / term - 0.0001);

        if (e < _013_ParamD || v > 1e6) break;
    }
    o = tanh(o *2);
    return float4(o.rgb, 1.0);
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader = mainImage(v_in);
    }
}
