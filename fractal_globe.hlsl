// fractal globe
// From Yohei Nishitsuji
// https://x.com/YoheiNishitsuji/status/1923362809569837131
// for(float i,g,e,s;++i<99.;){vec3 p=vec3((FC.xy-.5*r)/r.y*4.+vec2(0,1),g-6.)*rotate3D(3.,vec3(0,9,-3));p.xz*=rotate2D(t*.3);s=6.;for(int i;i++<12;p=vec3(0,4.03,-1)-abs(abs(p)*e-vec3(3,4,3)))s*=e=7.5/dot(p,p*.47);g+=p.y*p.y/s*.3;s=log2(s)-g*.8;o.rgb+=hsv(.5,.1,s/7e2);}
// Inspired from the above but I could not get the main fractal ball in the middle, not sure what I missed.
// [SGEORGET20250526003826]


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
float2 rotate2D(float a, float2 v) {
    float c = cos(a), s = sin(a);
    return float2(v.x * c - v.y * s, v.x * s + v.y * c);
}
float4 mainImage(VertData v_in) : TARGET {
    float2 r = uv_size;
    float t = elapsed_time / 10;
    float2 u = float2(v_in.uv.x * r.x, (1.0 - v_in.uv.y) * r.y); // Y-flip to match ShaderToy

    float4 o = 0;

    for (float i = 0., g = 0., e = 1.0, s = 0.; ++i < 99.;) {
        float3 A = float3(0.0, 9.0, -3.0) / 9.5;
        float3 p = float3(2.0 * ((u + u - r.xy) / r.y), g - 6.0);
        p.y += 1.0;

        // Approximate 3D rotation via analytical expression (rot3D equivalent)
        p = A * dot(p + p, A) - p - 0.14 * cross(p, A);

        // mat2-based rotate2D(t * .3)
        p.xz = rotate2D(t * 0.3, p.xz);

        s = 6.0;
        e = 1.0;
        for (int j = 0; j++ < 12;) {
            p = float3(0.0, 4.03, -1.0) - abs(abs(p) * e - float3(3.0, 4.0, 3.0));
            float d = dot(p, p);
            e = 16.0 / d;
            s *= e;
        }

        g += 0.3 * p.y * p.y / s;
        float brightness = (log2(s) - g * 0.8) / 700.0;
        o.rgb += brightness * float3(0.9, 1.0, 1.0); // pastel cyan glow
    }

    return float4(o.rgb, 1.0);
}

technique Draw {
    pass {
        vertex_shader = mainTransform(v_in);
        pixel_shader  = mainImage(v_in);
    }
}
