// Vortex
// From XorDev
// https://x.com/XorDev/status/1930594981963505793
// [SGEORGET20250608091937]


uniform float _017_Speed<
  string label = "Speed (0.2)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 2;
  float step = 0.01;
> = 0.2;



uniform float _017_Brightness<
  string label = "Brightness (1.5)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 1;
  float maximum = 8;
  float step = 0.1;
> = 1.5;



uniform int _017_Mode<
  string label = "Motion Mode (0)";
  string widget_type = "slider";
  string group = "Adjustments";
  int minimum = 0;
  int maximum = 4;
  int step = 1;
> = 0;



uniform float _017_Detail<
  string label = "Detail (9.0)";
  string widget_type = "slider";
  string group = "Adjustments";
  float minimum = 0;
  float maximum = 15;
  float step = 0.01;
> = 9.0;



struct VertData {
    float4 pos : POSITION;
    float2 uv  : TEXCOORD0;
};

VertData mainTransform(VertData v_in) {
    return v_in;
}

float4 mainImage(VertData v_in) : TARGET {
    float2 r = uv_size;
    float2 FC = float2(v_in.uv.x * r.x, (1 - v_in.uv.y) * r.y);
    float t = elapsed_time * _017_Speed;

    float i = 0.0;
    float z = frac(dot(float3(FC, 1.0), sin(float3(FC, 1.0))));
    float d = 0.0;
    float4 o = float4(0, 0, 0, 0);

    for (; i++ < 100.0;) {
        // vec3 p = z * normalize(FC.rgb * 2.0 - r.xyy);
        float3 fc3 = float3(FC, 0.0);
        float3 r_xyy;
        
        switch(_017_Mode)
        {
            case 1:
            r_xyy = float3(r.y*r.y/r.x, r.x*r.x/r.y, r.x);
            break;

            case 2:
            r_xyy = float3(r.x+1000*sin(t), r.y, r.y);
            break;

            case 3:
            r_xyy = float3(r.x, r.y+1000*sin(t), r.y);
            break;

            case 4:
            r_xyy = float3(r.x, r.y, r.y+1000*sin(t));
            break;


            default:
            r_xyy = float3(r.x, r.y, r.y);
            break;

        }
        float3 normVec = normalize(fc3 * 2.0 - r_xyy);
        float3 p = z * normVec;

        p.z += 6.0;

        d = 1.0;
        while (d < _017_Detail) {
            p += cos(p.yzx * d - t) / d;
            d /= 0.8;
        }

        d = 0.002 + abs(length(p) - 0.5) / 40.0;
        z += d;

        o += (sin(z - t + float4(6.0, 2.0, 4.0, 0.0)) + _017_Brightness) / d;
    }

    // Apply tanh contrast adjustment (component-wise)
    o = tanh(o / 7000.0);

    return o;
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
