shader_type canvas_item;

// O tamanho do círculo (1.05 = cobre a tela toda, 0.0 = tela toda preta)
uniform float circle_size : hint_range(0.0, 1.05) = 1.05;
// O centro do círculo na tela (0 a 1)
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    // Corrige o aspect ratio para o círculo não ficar oval (esticado)
    // Usamos SCREEN_PIXEL_SIZE para saber a proporção real da tela
    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    
    vec2 uv = SCREEN_UV;
    uv.x = (uv.x - 0.5) * aspect + 0.5;
    
    vec2 c = center;
    c.x = (c.x - 0.5) * aspect + 0.5;
    
    float dist = distance(uv, c);
    
    // Deixa transparente dentro do círculo e preto fora
    // O smoothstep dá uma bordinha bem leve de anti-aliasing
    COLOR.a = smoothstep(circle_size - 0.01, circle_size, dist);
    COLOR.rgb = vec3(0.0);
}
