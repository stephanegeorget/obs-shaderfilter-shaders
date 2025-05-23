// This shader was copied and adapted from XorDev
// Twitter account: https://x.com/XorDev
// Exact Tweet: https://x.com/XorDev/status/1920855494861672654
// See also: https://www.xordev.com/
// [SGEORGET20250523152517]


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


// User controls
// Good P1/P2: 0/0 (XorDev default),   22/23,  15/12,   4/9

uniform float _005_speed<
  string label = "Speed Adjustment (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0.0;
  float maximum = 3.0;
  float step = 0.01;
> = 0.2;


uniform int _005_P1<
  string label = "Param 1 (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 0;
  int maximum = 27;
  int step = 1;
> = 0;


uniform int _005_P2<
  string label = "Param 2 (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 0;
  int maximum = 27;
  int step = 1;
> = 0;



uniform float _005_P3<
  string label = "Param 3 (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = -2.0;
  float maximum = 2.0;
  float step = 0.01;
> = 0;



float4 mainImage(VertData v_in) : TARGET {
    float2 uv = v_in.uv;
    float2 size = uv_size;
    float t = elapsed_time * _005_speed;

    // 📐 Coordinate setup with pan + zoom + Y-flip
    float2 fragCoord = float2(uv.x * size.x, (1.0 - uv.y) * size.y);
    float3 FC = float3(fragCoord, 0.5);
    float3 r = float3(size.x, size.y, size.y);

    FC = float3(FC.xy, FC.z);

    float4 o = float4(0, 0, 0, 1);
    float i, z = 0.0, d;

    for (i = 0.; i++ < 50.;) {
        float3 v1, v2, v, p = z * normalize(FC * 2.0 - float3(r.x, r.y, r.y));
        p.z -= t;

        switch (_005_P1)
        {
            case 1: v1 = cos(p).xxx; break;
            case 2: v1 = cos(p).xxy; break;
            case 3: v1 = cos(p).xxz; break;
            case 4: v1 = cos(p).xyx; break;
            case 5: v1 = cos(p).xyy; break;
            case 6: v1 = cos(p).xyz; break;
            case 7: v1 = cos(p).xzx; break;
            case 8: v1 = cos(p).xzy; break;
            case 9: v1 = cos(p).xzz; break;
            case 10: v1 = cos(p).yxx; break;
            case 11: v1 = cos(p).yxy; break;
            case 12: v1 = cos(p).yxz; break;
            case 13: v1 = cos(p).yyx; break;
            case 14: v1 = cos(p).yyy; break;
            case 15: v1 = cos(p).yyz; break;
            case 16: v1 = cos(p).yzx; break;
            case 17: v1 = cos(p).yzy; break;
            case 18: v1 = cos(p).yzz; break;
            case 19: v1 = cos(p).zxx; break;
            case 20: v1 = cos(p).zxy; break;
            case 21: v1 = cos(p).zxz; break;
            case 22: v1 = cos(p).zyx; break;
            case 23: v1 = cos(p).zyy; break;
            case 24: v1 = cos(p).zyz; break;
            case 25: v1 = cos(p).zzx; break;
            case 26: v1 = cos(p).zzy; break;
            case 27: v1 = cos(p).zzz; break;
            default: v1 = cos(p);break;
        }
    
            switch (_005_P2)
        {
            case 1: v2 = sin(p).xxx; break;
            case 2: v2 = sin(p).xxy; break;
            case 3: v2 = sin(p).xxz; break;
            case 4: v2 = sin(p).xyx; break;
            case 5: v2 = sin(p).xyy; break;
            case 6: v2 = sin(p).xyz; break;
            case 7: v2 = sin(p).xzx; break;
            case 8: v2 = sin(p).xzy; break;
            case 9: v2 = sin(p).xzz; break;
            case 10: v2 = sin(p).yxx; break;
            case 11: v2 = sin(p).yxy; break;
            case 12: v2 = sin(p).yxz; break;
            case 13: v2 = sin(p).yyx; break;
            case 14: v2 = sin(p).yyy; break;
            case 15: v2 = sin(p).yyz; break;
            case 16: v2 = sin(p).yzx; break;
            case 17: v2 = sin(p).yzy; break;
            case 18: v2 = sin(p).yzz; break;
            case 19: v2 = sin(p).zzz; break;
            case 20: v2 = sin(p).zxx; break;
            case 21: v2 = sin(p).zxy; break;
            case 22: v2 = sin(p).zxz; break;
            case 23: v2 = sin(p).zyx; break;
            case 24: v2 = sin(p).zyy; break;
            case 25: v2 = sin(p).zyz; break;
            case 26: v2 = sin(p).zzx; break;
            case 27: v2 = sin(p).zzy; break;

            default: v2 = -sin(p).yzx;break;
        }
        v = v1 - v2 + _005_P3 ;
        float3 folded = max(v, v.yzx * 0.2);
        d = 0.5 * length(folded);
        z += d;

        o.rgb += (cos(p) + 1.2) / d;
    }

    o.rgb /= (o.rgb + 1000.0);
    o.a = 1.0;
    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
