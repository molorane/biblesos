import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biblesos/presentation/widgets/premium_hymn_viewer.dart' as viewer;

// View modes: Grid or List
enum HymnViewMode { grid, list }

class HymnViewModeNotifier extends Notifier<HymnViewMode> {
  @override
  HymnViewMode build() => HymnViewMode.grid;
  void set(HymnViewMode mode) => state = mode;
}

final hymnViewModeProvider = NotifierProvider<HymnViewModeNotifier, HymnViewMode>(
  HymnViewModeNotifier.new,
);

class HymnSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final hymnSearchQueryProvider = NotifierProvider<HymnSearchQueryNotifier, String>(
  HymnSearchQueryNotifier.new,
);

class TsaSioneScreen extends ConsumerStatefulWidget {
  const TsaSioneScreen({super.key});

  static Map<String, String> getHymns() {
    return {
      "1": "Pele Lentswe La Na La Re - T. Arbousset",
      "2": "Ho 'Mopi Wa Batho - E. Casalis",
      "3": "Pela Tulo Se Tshabehang - F. Coillard",
      "4": "Ketso Tsa Hao, Ntate - S. Rolland",
      "5": "Oa Kganya, Mong'a Marena. - E. Casalis",
      "6": "Dithabeng Le Dithoteng - A. Mabille",
      "7": "Jehova, Modimo oa Israele - E. Casalis",
      "8": "Jehova, Morena Wa Ka - T. Arbousset",
      "9": "Moya Wa Ka, O Rorise Modimo - E. Casalis",
      "10": "Tlo Monghadi Wa Ho Phela - S. Rolland",
      "11": "Bokang Modimo oa Khanya - S. Rolland",
      "12": "Rea O Boka, Morena - S. Rolland",
      "13": "A Re Leboheng Morena - S. Rolland",
      "14": "Morena, Litshitso Tsa Hao - T. Arbousset",
      "15": "Jehova o kgabane - S. Rolland",
      "16": "Modim'o Ratile Batho - S. Rolland",
      "17": "Ea itshepelang Modimo - H. Marzolff",
      "18": "Tlong, Re Roriseng Kaofela - S. Rolland",
      "19": "Ea Renang Ka Ho Sa Feleng - S. Rolland",
      "20": "Ba Ratilweng Ke Modimo - S. Rolland",
      "21": "Re Roriseng Ea Re Makatsang - S. Rolland",
      "22": "A Re Bineng Kajeno - T. Arbousset",
      "23": "Elelloang Ba Bochabela - T. Arbousset",
      "24": "Hosanna Ho Ea Tlang - S. Rolland",
      "25": "A Re Eteleng Bethlehema - L. Duvoisin",
      "26": "Alleluya, Alleluya! - A. Mabille",
      "27": "Bonang Sefapanong - S. Rolland",
      "28": "Lefu La Hao, Molopolli - T. Arbousset",
      "29": "Ke Soabisitswe Modimo, - S. Rolland",
      "30": "Topollo, Lebitso Lena - T. Arbousset",
      "31": "Lefu La Hao La Mahlomola - E. Rolland",
      "32": "Bonang Lerato La Jesu - T. Arbousset",
      "33": "Jesu O Tsohile Bafung! - T. Arbousset",
      "34": "Jesu O Tsohile Bafung - S. Rolland",
      "35": "Se Tumisoang Nģalong Ena - S. Rolland & E. Casalis",
      "36": "Re Tumiseng Ka Dipina - S. Rolland",
      "37": "Bakgethoa, Tsohelang - S. Rolland",
      "38": "Morena O Tsohile - A. Mabille",
      "39": "Jesu A Nyoloha - S. Rolland",
      "40": "Fatshe Ke La Morena, - F. Daumas",
      "41": "Jesu O Kgutletse - S. Rolland",
      "42": "A Re Roriseng Mor'a Motho - L. Duvoisin",
      "43": "Jesu O Rapella Sechaba - S. Rolland",
      "44": "Tsohang Baena, Lebelang - S. Rolland",
      "45": "Bonang Ho Hlahile Marung - E. Casais",
      "46": "Bonang, Oa Tla, 'Moloki Wa batho - T. Jousse",
      "47": "Lona Bakgethoa - A. Mabille",
      "48": "Fadimehang bakreste, - A. Mabille",
      "49": "Jesu, Lebitso Le Letle! - S. Rolland",
      "50": "Re Tumiseng Dithoko - S. Rolland",
      "51": "Lerato la Jesu le re tlosa melato - S. Rolland",
      "52": "Ho rata Jesu - S. Rolland",
      "53": "Joko ea Hao - E. Casalis",
      "54": "A re bokeng Jesu - S. Rolland",
      "55": "Mor'a Modimo Konyana - T. Arbousset",
      "56": "Konyana Konyana - S. Rolland",
      "57": "A re bineleng Jesu - L. Duvoisin",
      "58": "Ho Morena - F. Ellenberger",
      "59": "Modimo e s'e le dinako - S. Rolland",
      "60": "Tlo, Moea o Halalelang - S. Rolland",
      "61": "Leeba la lehodimo - E. Casalis",
      "62": "Foka moya wa bophelo - S. Rolland",
      "63": "Moy'a Ntate Mobonesi - S. Rolland",
      "64": "Moya mohlodi wa batho - S. Rolland",
      "65": "Tlo Moya o Halalelang - F. Ellenberger",
      "66": "Tlong kaofela ditabeng tse molemo - S. Rolland",
      "67": "Nyakallang Lefatshe Lohle - S. Rolland",
      "68": "Ditjhaba Tsohle tsa Lefatshe - T. Arbousset",
      "69": "Thaba, molahlehi, - S. Rolland",
      "70": "Naha Tsohle tsa Lefatshe - S. Rolland",
      "71": "Ba nyorilweng le tle metsing - E. Casalis",
      "72": "Moetsadibe tlo koano - A. Mabille",
      "73": "Ngoana ea letsoalo - F. Coillard",
      "74": "Akofa Motho O Se Re - A. Mabille",
      "75": "Bohle Ba Ratang Ho Phela - L. Duvoisin",
      "76": "Utloang Bohle Ditaba Tse Molemo - E. Rolland",
      "77": "Setulo Se Teng Sa Borena - L. Duvoisin",
      "78": "Fadimeha, Sebaka Ha Se Kganya - H. Marzolff",
      "79": "Morena, O Ba Etele - S. Rolland",
      "80": "Jesu O Tla Busa - S. Rolland",
      "81": "Bahetene Ba Timela - S. Rolland",
      "82": "Lentswe la Hao, 'Mueledi - S. Rolland",
      "83": "Tsee ke Leng ho Tsona Feela - S. Rolland",
      "84": "Ha ke Fuputsa Bukeng ya Bophelo - F. Ellenberger",
      "85": "Moren'a ka, Lentswe la Hao - L. Duvoisin",
      "86": "Dibe Di Teng, Rea Di Bona - E. Casalis",
      "87": "Dibe tsa batho - T. Arbousset",
      "88": "Batho ba sa tsebeng Jesu - S. Rolland",
      "89": "Se Teng Sediba Sa Madi - S. Rolland",
      "90": "Tlong ba Heso Re Ithute Lerato - T. Arbousset",
      "91": "Re Rata Ha Re Ka Bona - E. Casalis",
      "92": "Dibe Tsena Tsa Ka - A. Mabille",
      "93": "Kgalefo Ya Hao, Morena - S. Rolland",
      "94": "Bofumanehing Ba Ka - S. Rolland",
      "95": "A Re Tshabeng Tsela e Mpe - S. Rolland",
      "96": "Ke Tla Tsoha, Ke Tla Tsoha - F. Lemue",
      "97": "Ke Lesitsi, Ke Tla Feela - R. Rapetloane",
      "98": "Nku e Lahlehileng - F. Coillard",
      "99": "Bodibeng Joa Mahlomola - L. Duvoisin",
      "100": "Ke Dumetse Ho Morena - S. Rolland",
      "101": "Mekete ya Lefatshe - S. Rolland",
      "102": "Le Monate, le Monate - A. Mabille",
      "103": "'Moloki Wa Ka ea Ratehang - A. Mabille",
      "104": "Ho Loka ha Jesu Kreste - L. Duvoisin",
      "105": "Ke Ngoan'a Hao - S. Rolland",
      "106": "Morena, Ho Hotle Hakaakang - L. Duvoisin",
      "107": "Hlohonolo Ke La Ba Sa Rateng - E. Casalis",
      "108": "Ha Le Mpotsa Tshepo Ya Ka - E. Casalis",
      "109": "Jesu Ke Setshabelo - S. Rolland",
      "110": "Ntate, Ha Ke Sa Sepela - S. Rolland",
      "111": "Ke Na Le Modisa - S. Rolland",
      "112": "Lefatshe Lena - Le Ka 'nea'ng? - S. Rolland",
      "113": "Jesu, Ha Ke Batle Thuso - A. Mabille",
      "114": "Tlohang Ho 'na, Nyakallo Tsa Lefatshe - S. Rolland",
      "115": "O Modimo Wa Ka, Modimo Wa Topollo! - S. Rolland",
      "116": "Ha Le Lakatsa Ho Tseba - A. Mabille",
      "117": "Tsietsing tsa Letsoalo - S. Rolland",
      "118": "Modimo, Ha O Ipata - T. Arbousset",
      "119": "Modimo Ke Setshabelo - A. Mabille",
      "120": "Ea Itshepelang 'Moloki - S. Rolland",
      "121": "Mofapahloho O Teng - F. Ellenberger",
      "122": "Ea Hlolang - L. Duvoisin",
      "123": "Jesu Kreste ke Seboko Sa Rona - S. Rolland",
      "124": "Re Phokoleng Fela Sa Hlolo - S. Rolland",
      "125": "Dintle Tsa Hao Di Teng Ho 'Na - T. Arbousset",
      "126": "Ntat'a Rona ea Hodimo, - T. Arbousset",
      "127": "Tlo Jesu, Mong 'a Kgale - T. Arbousset",
      "128": "Modisa ea Batlang Dinku - E. Casalis",
      "129": "Jesu, ke Utloa Ha O Re - E. Casalis",
      "130": "Ngaka Ya Lefu la Dibe - E. Casalis",
      "131": "Ke Thaba Ha ke Bala Bibeleng - L. Duvoisin",
      "132": "O Modimo O Tletseng Mosa - A. Mabille",
      "133": "A re Rateng ka Cheseho - S. Rolland",
      "134": "Morena, Ke Rata Ho O Phelela - L. Duvoisin",
      "135": "Sedi La Ka - A. Mabille",
      "136": "Modimo, Ke Tshaba Ha Ke e-ba Lekala - A. Mabille",
      "137": "Ana Ke Ntho E Ka Etsoang - F. Coillard",
      "138": "Haufi Le Morena - E. Rolland",
      "139": "Leetong La Rona La Lehodimo - E. Rolland",
      "140": "Dillo Tsa Mahlomola-pelo - E. Rolland",
      "141": "Ho Hotle Ho Bona - T. Arbousset",
      "142": "Ho Roriswe Rato Lena - S. Rolland",
      "143": "Dipelo Ha Di Teane - L. Duvoisin",
      "144": "Morena, Phutheho ya Hao - S. Rolland",
      "145": "O Tla Tloha O Hauhele - E. Rolland",
      "145A": "Faphang Jesu Ka Dithoko - R. A. Paroz",
      "146": "Moo Ke Eben-Ezer - F. Coillard",
      "147": "Bomadimabe bo bokaakang - F. Coillard",
      "148": "Re Bafeti moo Lefatsheng - T. Arbousset",
      "149": "Dilemo Tsa Bocha E ka Palesa - A. Mabille",
      "150": "Tshiu Tsa ka Tse Fetileng - A. Mabille",
      "151": "Ditshiu Tsa Ka Dia Phalla - F. Coillard",
      "152": "Ntate Ea Mohau - S. Rolland",
      "153": "Jehova, Moren’a Rona - S. Rolland",
      "154": "Selemo Sena Se Setjha  - S. Rolland",
      "155": "Fatshe Lea Feta - S. Rolland",
      "156": "Jo, Ho Phela Ha Rona ke'ng? - F. Coillard",
      "157": "Dumela Hhe Nako E Se E Tlile - S. Rolland",
      "158": "Itlhakoleng Dillo - S. Rolland",
      "159": "Kajeno Ngoan'abo Rona - F. Coillard",
      "160": "Kajeno Re Tlil'o Llela - F. Daumas",
      "161": "Tlong, Re Yeng - A. Mabille",
      "162": "Re Ba Nyoretsweng Lefatshe Le Edileng - A. Mabille",
      "163": "Ke Habile Lehodimong - F. Coillard",
      "164": "Lefatsheng Lena Ke Tla Tloha - A. Mabille",
      "165": "Ho Hlola Le Wena - F. Coillard",
      "166": "Ka Madi A Hao A Matle - L. Duvoisin",
      "167": "Hole Le Hae La Ka - E. Rolland",
      "168": "Ke Boloketswe Phomolo - A. Mabille",
      "169": "Na Letsatsi Le Tla Nchabela Neng - E. Casalis",
      "170": "Motse o Teng Hodimo - E. Casalis",
      "171": "Fatshe Le Teng La Nyakallo - S. Rolland",
      "172": "Ke Rata Ho Nyakalla - S. Rolland",
      "173": "E Monateng Ke Sioneng - S. Rolland",
      "174": "Jerusalema Oa Benya - S. Rolland",
      "175": "Ke Bonela Lehodimo - A. Mabille",
      "176": "Re Se Re Tlohile - S. Rolland",
      "177": "Tieang Pelo Ho Kena Tlung Ya Khanya - S. Rolland",
      "178": "Ha Re Babatsa Hakalo - F. Coillard",
      "179": "Tsatsi Le Leholo - T. Arbousset",
      "180": "Re Kene Ka Thothomelo - S. Rolland",
      "181": "O Kgethelwe Tsatsi Lena - S. Rolland",
      "182": "Pelo Ya Ka Ea O Batla - S. Rolland",
      "183": "Atamelang Ho Jehova - T. Arbousset",
      "184": "A Re Phokoleng Sefela - S. Rolland",
      "185": "Na Hase Ntho E Ratehang - T. Arbousset",
      "186": "Itleleng Pel'a Morena - T. Arbousset",
      "187": "Kgama e Siileng Letsholo - E. Casalis",
      "188": "Kajeno Re Rorisa - F. Daumas",
      "189": "Rapellang Jerusalema - S. Rolland",
      "190": "Modimo Wa 'Nete - S. Rolland",
      "191": "Ka Dipelo Tse Monate - S. Rolland",
      "192": "Tshebeletso Ya Modimo - S. Rolland",
      "193": "Tiisa Lentswe Lena - S. Rolland",
      "194": "Joale Re Utloile Ditaba - E. Casalis",
      "195": "E, Joale Ke Tla Goroga - T. Arbousset",
      "196": "Moruo Wa Lehodimo - E. Casalis",
      "197": "Jesu Modis'a Molemo - T. Arbousset",
      "198": "Letsatsi La Lehlohonolo - S. Rolland",
      "199": "Lentswe Le Dumang Sebakeng - E. Casalis",
      "200": "Lona Ba Ratang Go Phela - E. Casalis",
      "201": "Binang Mohlatsoana - S. Rolland",
      "202": "Tlong Re Busetseng Lerato - S. Rolland",
      "203": "Duduetsang Ka Pina - S. Rolland",
      "204": "Ke Tela Satane - S. Rolland",
      "205": "Kajeno Ho Nchabetse - A. Mabille",
      "206": "Nakong Ya Selallo le Pel'a Mahlomola - T. Arbousset",
      "207": "A Re Bokeng Mor'a Motho - S. Rolland",
      "208": "Le Atamele Tafole - T. Jousse",
      "209": "Jesu Bohobe Ba Bophelo - S. Rolland",
      "210": "Jesu O Mpone Ha Ke Kgathetse - F. Coillard",
      "210A": "Balopolloa Ba Morena - A. Mabille",
      "211": "Jesu, Ha O Ile - A. Mabille",
      "211A": "Ke Utlwa Lerato - A. Mabille",
      "212": "Dumelang banyadi, - E. Casalis",
      "213": "Morena Banyadi Bana - S. Rolland",
      "214": "Ke Nģalo e Kgethehileng - F. Coillard",
      "215": "Mong 'a Lesedi Rabophelo - S. Rolland",
      "216": "Ke Bone Hape Lesedi - T. Arbousset",
      "400": "Taba Tsa Letsoalo - S. Rolland",
      "401": "Jesu ke Setshabelo Sa Ka - S. Rolland",
      "402": "Bonang Lerato La Modimo - S. Rolland",
      "403": "Hosanna Ho Jesu! - S. Rolland",
      "404": "Ke Moeti Fatsheng Lena - S. Rolland",
      "405": "Jesu O Re Lerato - S. Rolland",
      "406": "Oho! Se Ntebale, Jesu - S. Rolland",
      "407": "Modimo O Lerato Hakaka - S. Rolland",
      "408": "Oho! Re Hauhele, Ntate - S. Rolland",
      "409": "Morena, Re Hopole - S. Rolland",
      "410": "Oho! Re Boloke, Jesu - S. Rolland",
      "411": "Jehova O S'a Re Thusitse - S. Rolland",
      "412": "Jesu O S'a Re Namotse - S. Rolland",
      "413": "Morena O S'a Re Falotse - S. Rolland",
      "414": "Jesu O S'a Re Thusitse Ruri - S. Rolland",
      "415": "Morena O S'a Re Namotse Ruri - S. Rolland",
      "416": "Jesu O S'a Re Falotse Ruri - S. Rolland",
      "417": "Morena O S'a Re Thusitse Ruri Hape - S. Rolland",
      "418": "Jesu O S'a Re Namotse Ruri Hape - S. Rolland",
      "419": "Morena O S'a Re Falotse Ruri Hape - S. Rolland",
      "420": "Jesu O S'a Re Thusitse Ruri Hape Hona Joale - S. Rolland",
      "421": "Morena O S'a Re Namotse Ruri Hape Hona Joale - S. Rolland",
      "422": "Jesu O S'a Re Falotse Ruri Hape Hona Joale - S. Rolland",
      "423": "Morena O S'a Re Thusitse Ruri Hape Hona Joale Ruri - S. Rolland",
      "424": "Jesu O S'a Re Namotse Ruri Hape Hona Joale Ruri - S. Rolland",
      "425": "Morena O S'a Re Falotse Ruri Hape Hona Joale Ruri - S. Rolland",
      "426": "Jesu O S'a Re Thusitse Ruri Hape Hona Joale Ruri Hape - S. Rolland",
      "427": "Morena O S'a Re Namotse Ruri Hape Hona Joale Ruri Hape - S. Rolland",
      "428": "Jesu O S'a Re Falotse Ruri Hape Hona Joale Ruri Hape - S. Rolland",
      "429": "Ruri, Jesu Ke 'Moloki - F. Coillard",
      "430": "Hohle, Hohle, Jesu Ke 'Moloki - F. Coillard",
      "431": "Mmele, Moya Le Letsoalo - F. Coillard",
      "432": "Morena, Re Nehe Moya - F. Coillard",
      "433": "Jesu Mong'a Ka O Filwe Borena - F. Coillard",
      "434": "Lefatshe Le Tahang - F. Coillard",
      "435": "Bonang, Rato Le Lekaakang - F. Coillard",
      "436": "Ke Moeti, Ke Le Tseleng - F. Coillard",
      "437": "Duduetsang, Chaba Tsohle - F. Coillard",
      "438": "Oho, Se Fele Pelo - F. Coillard",
      "439": "Ba Bitseng, Le Ba Qophelle - F. Coillard",
      "440": "Na Le Re Phomolo E Teng - E. Casalis",
      "441": "Utloa Sello Sa Dichaba - F. Coillard",
      "442": "Jesu, Ha Ke Batle Thuso - A. Mabille",
      "443": "Se Sa Le Teng, Sebaka Bohading - H. Marzolff",
      "444": "Re Bahlanka Ba Hao Ba Bokgabane - H. Marzolff",
      "445": "Modimo Ke Moya - J. P. Mohapeloa",
      "446": "Utloa Sefefo - H. Marzolff",
      "447": "Ke Golgotha - L. Duvoisin",
      "448": "Melomo Ya Rona E Rorise Morena - H. Marzolff",
      "449": "Jehova, Moren'a Topollo Ya Ka - H. Marzolff",
      "450": "Tla Re Yeng Ba Rategang - Circuit Rider",
    };
  }

  @override
  ConsumerState<TsaSioneScreen> createState() => _TsaSioneScreenState();
}

class _TsaSioneScreenState extends ConsumerState<TsaSioneScreen> {
  @override
  void initState() {
    super.initState();
    // Reset search query when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hymnSearchQueryProvider.notifier).set('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hymns = TsaSioneScreen.getHymns();
    final searchQuery = ref.watch(hymnSearchQueryProvider);

    // Filter hymns based on search query
    final filteredHymns = hymns.entries.where((entry) {
      final query = searchQuery.toLowerCase();
      return entry.key.contains(query) || entry.value.toLowerCase().contains(query);
    }).toList();

    // Sort filtered hymns numerically
    filteredHymns.sort((a, b) {
      final aNum = int.tryParse(a.key) ?? 0;
      final bNum = int.tryParse(b.key) ?? 0;
      return aNum.compareTo(bNum);
    });

    final viewMode = ref.watch(hymnViewModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tsa Sione',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: Icon(viewMode == HymnViewMode.grid ? Icons.list : Icons.grid_view),
            onPressed: () {
              ref.read(hymnViewModeProvider.notifier).set(
                viewMode == HymnViewMode.grid ? HymnViewMode.list : HymnViewMode.grid,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (value) => ref.read(hymnSearchQueryProvider.notifier).set(value),
              decoration: InputDecoration(
                hintText: 'Search by number or title...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: viewMode == HymnViewMode.grid
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final hymn = filteredHymns[index];
                      return _buildHymnGridTile(context, hymn.key, hymn.value, isDark);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final hymn = filteredHymns[index];
                      return _buildHymnListTile(context, hymn.key, hymn.value, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHymnGridTile(BuildContext context, String number, String title, bool isDark) {
    return InkWell(
      onTap: () => _openHymnDetail(context, number, title),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHymnListTile(BuildContext context, String number, String title, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => _openHymnDetail(context, number, title),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFBD10E0).withOpacity(0.1),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFFBD10E0),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: isDark ? Colors.white30 : Colors.black26,
        ),
      ),
    );
  }

  void _openHymnDetail(BuildContext context, String number, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HymnDetailScreen(number: number, title: title),
      ),
    );
  }
}

class HymnDetailScreen extends ConsumerWidget {
  final String number;
  final String title;

  const HymnDetailScreen({
    super.key,
    required this.number,
    required this.title,
  });

  Future<List<viewer.HymnPart>> _parseHymnContent(String rawContent) async {
    final lines = rawContent.split('\n');
    final content = <viewer.HymnPart>[];
    
    String currentStanza = '';
    int? currentNumber;

    // Skip the first line as it's the header
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) {
        if (currentStanza.isNotEmpty) {
          content.add(viewer.HymnPart(
            text: currentStanza.trim(),
            type: viewer.HymnPartType.stanza,
            number: currentNumber,
          ));
          currentStanza = '';
          currentNumber = null;
        }
        continue;
      }

      // Check if line starts with a number (stanza number)
      final match = RegExp(r'^(\d+)\s+(.*)').firstMatch(line);
      if (match != null) {
        if (currentStanza.isNotEmpty) {
          content.add(viewer.HymnPart(
            text: currentStanza.trim(),
            type: viewer.HymnPartType.stanza,
            number: currentNumber,
          ));
        }
        currentNumber = int.tryParse(match.group(1)!);
        currentStanza = match.group(2)! + '\n';
      } else {
        currentStanza += line + '\n';
      }
    }

    if (currentStanza.isNotEmpty) {
      content.add(viewer.HymnPart(
        text: currentStanza.trim(),
        type: viewer.HymnPartType.stanza,
        number: currentNumber,
      ));
    }

    return content;
  }

  Future<String> _loadRawContent() async {
    return await rootBundle.loadString('assets/tsa-sione/$number.txt');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hymns = TsaSioneScreen.getHymns();

    // Split title and author
    final titleParts = title.split(' - ');
    final mainTitle = titleParts[0];
    final author = titleParts.length > 1 ? titleParts[1] : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hymn $number',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<String>(
        future: _loadRawContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFBD10E0)));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load hymn content'));
          }

          return FutureBuilder<List<viewer.HymnPart>>(
            future: _parseHymnContent(snapshot.data!),
            builder: (context, contentSnapshot) {
              if (contentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFBD10E0)));
              }
              
              final sortedKeys = hymns.keys.toList()..sort((a, b) {
                final aN = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                final bN = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                return aN.compareTo(bN);
              });
              final currentIndex = sortedKeys.indexOf(number);
              
              return viewer.PremiumHymnViewer(
                id: number,
                title: mainTitle,
                author: author,
                content: contentSnapshot.data ?? [],
                themeColor: const Color(0xFFBD10E0),
                onNext: currentIndex < sortedKeys.length - 1 
                    ? () {
                        final nextKey = sortedKeys[currentIndex + 1];
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HymnDetailScreen(
                              number: nextKey,
                              title: hymns[nextKey]!,
                            ),
                          ),
                        );
                      }
                    : null,
                onPrevious: currentIndex > 0 
                    ? () {
                        final prevKey = sortedKeys[currentIndex - 1];
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HymnDetailScreen(
                              number: prevKey,
                              title: hymns[prevKey]!,
                            ),
                          ),
                        );
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
