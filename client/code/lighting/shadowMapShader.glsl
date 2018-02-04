#define PI 3.14

extern number resolutionY;
extern number maxResolution;

const float ALPHA_THRESHOLD = 0.00001;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    number distance = 1.0;

    // Iterate through the occluder map's y-axis.
    for (number y = 0.0; y < resolutionY; y++) {
        // Rectangular to polar
        vec2 norm = vec2(texture_coords.s * (maxResolution / resolutionY), y / resolutionY) * 2.0 - 1.0;
        number theta = PI * 1.5 + norm.x * PI;
        number r = (1.0 + norm.y) * 0.5;

        // coord which we will sample from occlude map
        vec2 coord = vec2(-r * sin(theta), -r * cos(theta)) / 2.0 + 0.5;

        // sample the occlusion map
        vec4 data = Texel(texture, coord * (resolutionY / maxResolution));

        // the current distance is how far from the top we've come
        number dst = y / resolutionY;

        // if we've hit an opaque fragment (occluder), then get new distance
        // if the new distance is below the current, then we'll use that for our ray
        number caster = data.a;

        if (caster > ALPHA_THRESHOLD) {
            distance = min(distance, dst);
            break;
            // NOTE: we could probably use "break" or "return" here
        }
    }

    return vec4(vec3(distance), 1.0);
}
