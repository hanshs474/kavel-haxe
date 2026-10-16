import kavel.Kavel;

class Main {
	static function main() {
		try {
			Kavel.generate("   ");
			trace("FAIL: empty prompt accepted");
		} catch (e:KavelError) trace("ok: " + e.message);
		try {
			trace(Kavel.generate(Sys.args().length > 0 ? Sys.args().join(" ") : "a paper-cut fox in a moonlit forest"));
		} catch (e:KavelError) trace("kavel: " + e.message);
	}
}
