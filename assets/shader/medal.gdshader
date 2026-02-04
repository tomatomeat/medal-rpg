shader_type canvas_item;
render_mode unshaded;

// 円の半径（0.0～1.0）
uniform float radius : hint_range(0.0, 1.0) = 0.5;
// 円の中心（UV）
uniform vec2 center = vec2(0.5, 0.5);
// エッジのぼかし
uniform float smoothness : hint_range(0.0, 0.1) = 0.01;

// 自動スムージング付きテクスチャ取得
vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size)
{
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);
	
	vec2 uv_pixels = uv / pixel_size;
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp(
		(uv_dxy_pixels - vec2(0.5)) * pixel_size / lxy + vec2(0.5),
		0.0, 1.0
	);
	
	uv = uv_pixels_floor * pixel_size;
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

void fragment()
{
	vec2 uv = UV;

	// スムージング付きでテクスチャ取得
	vec4 color = texturePointSmooth(TEXTURE, uv, TEXTURE_PIXEL_SIZE);

	// 中心からの距離
	float dist = distance(uv, center);

	// 円形マスク（外側をフェードアウト）
	float mask = 1.0 - smoothstep(radius, radius + smoothness, dist);

	COLOR = vec4(color.rgb, color.a * mask);
}
