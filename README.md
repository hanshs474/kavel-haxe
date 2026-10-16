# kavel

Kavel is a free AI video generator and AI image generator — 4K clips with sound, and images you can run without an account or a card. This library calls it from Haxe: one static function, standard library only, on every sys target (eval, hl, cpp, neko, python, jvm).

```haxe
import kavel.Kavel;

trace(Kavel.generate("a paper-cut fox in a moonlit forest"));
// https://cdn.kavel.ai/uploads/…/….webp
```

No key is needed for a first try: the call runs on Kavel's free allowance.

```sh
haxelib install kavel
```

## Past the free allowance

Create an API key on your Kavel account at https://www.kavel.ai/settings/apikeys and pass it (or set `KAVEL_API_KEY`):

```haxe
Kavel.generate("isometric tiny greenhouse", Sys.getEnv("KAVEL_API_KEY"), "gpt-image-2");
```

With a key the call runs on your account: your credits, and the image models your [plan](https://www.kavel.ai/pricing?utm_source=haxelib) includes. Every failure throws `KavelError` with a readable reason — spent allowance, refused prompt, wrong key or timeout.

## More from Kavel

Editing a photo instead of starting from a prompt? Kavel keeps a page per edit — [hairstyle](https://www.kavel.ai/image/ai-hairstyle-changer?utm_source=haxelib), [outfit](https://www.kavel.ai/image/ai-outfit-generator?utm_source=haxelib) and the rest under [AI image tools](https://www.kavel.ai/image?utm_source=haxelib). Video lives under [AI video tools](https://www.kavel.ai/video?utm_source=haxelib).

MIT licensed.
