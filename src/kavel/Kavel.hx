package kavel;

import haxe.Json;
import haxe.Http;

/**
	Generate an AI image with Kavel (https://www.kavel.ai) from Haxe.

	Kavel is a free AI video generator and AI image generator. Without an API key a
	call runs on Kavel's free allowance (text to image). With a key — `apiKey`, or the
	`KAVEL_API_KEY` environment variable — it runs on your Kavel account: your credits
	and the image models your plan includes.

	Works on sys targets (eval, hl, cpp, neko, python, jvm).

	```haxe
	trace(kavel.Kavel.generate("a paper-cut fox in a moonlit forest"));
	```
**/
class Kavel {
	public static inline var BASE_URL = "https://www.kavel.ai";
	public static inline var KEYS_URL = "https://www.kavel.ai/settings/apikeys";
	static inline var FREE_MODEL = "kavel-image-v1";
	static inline var USER_AGENT = "kavel-haxe/0.1.0";

	/** Generates one image and returns its URL. Throws `KavelError` with a readable reason. **/
	public static function generate(prompt:String, ?apiKey:String, ?model:String, aspectRatio = "1:1", timeoutSec = 360,
			pollEverySec = 5):String {
		var text = StringTools.trim(prompt == null ? "" : prompt);
		if (text == "")
			throw new KavelError("write a prompt first");
		var key = (apiKey != null && apiKey != "") ? apiKey : Sys.getEnv("KAVEL_API_KEY");
		var keyed = key != null && key != "";
		var anon = "hx-" + StringTools.hex(Std.random(0x7fffffff), 8) + StringTools.hex(Std.random(0x7fffffff), 8);

		var submit = call("POST", BASE_URL + "/api/ai/generate", {
			provider: "kie",
			mediaType: "image",
			model: (keyed && model != null && model != "") ? model : FREE_MODEL,
			scene: "text-to-image",
			prompt: text,
			options: {aspect_ratio: aspectRatio}
		}, keyed ? key : null, anon);
		if (submit.code != 0)
			throw new KavelError(submit.message != null ? submit.message : "request refused");
		var data:Dynamic = submit.data;
		if (data != null && data.wall == true)
			throw new KavelError("the free allowance is spent - pass an API key from " + KEYS_URL);
		var task:String = data != null ? data.id : null;
		if (task == null || task == "")
			throw new KavelError("Kavel returned no task id");

		var deadline = Sys.time() + timeoutSec;
		while (Sys.time() < deadline) {
			Sys.sleep(pollEverySec);
			var env:Dynamic = try {
				keyed ? call("POST", BASE_URL + "/api/ai/query", {taskId: task}, key, anon) : call("GET",
					BASE_URL + "/api/ai/anon-query?taskId=" + StringTools.urlEncode(task) + "&provider=kie&mediaType=image", null, null, anon);
			} catch (e:Dynamic) null; // a dropped poll is not a failed generation
			if (env == null || env.code != 0)
				continue;
			var d:Dynamic = env.data;
			if (d == null)
				continue;
			if (d.status == "failed")
				throw new KavelError("generation failed - try another prompt");
			for (field in ["cleanImages", "images"]) {
				var imgs:Array<Dynamic> = Reflect.field(d, field);
				if (imgs != null && imgs.length > 0)
					return Std.isOfType(imgs[0], String) ? imgs[0] : imgs[0].url;
			}
		}
		throw new KavelError('still running after $timeoutSec seconds (task $task)');
	}

	static function call(method:String, url:String, body:Dynamic, key:Null<String>, anon:String):Dynamic {
		var h = new Http(url);
		h.setHeader("User-Agent", USER_AGENT);
		if (key != null)
			h.setHeader("Authorization", "Bearer " + key);
		else
			h.setHeader("x-anon-id", anon);
		if (body != null) {
			h.setHeader("Content-Type", "application/json");
			h.setPostData(Json.stringify(body));
		}
		var out:String = null;
		h.onData = s -> out = s;
		h.onError = msg -> if (out == null) out = h.responseData;
		h.request(method == "POST");
		try {
			return Json.parse(out);
		} catch (e:Dynamic) {
			return {code: -1, message: "unexpected reply from Kavel"};
		}
	}
}

class KavelError extends haxe.Exception {}
