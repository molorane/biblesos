import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Map<String, String> _getHymns() {
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
      "113": "Jesu, Ha Ke Bitsa - S. Rolland",
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
      "217": "Jesu Naledi Ya Ho Sa - S. Rolland",
      "218": "Ntat'a Rona Modimo Wa Hloleho - S. Rolland",
      "219": "Morena E Sa Le Hosasa - L. Duvoisin",
      "220": "Letsatsi le Phirimile - E. Casalis",
      "221": "Kea Leboha Modimo - S. Rolland",
      "222": "Lala Ho Nna - E. Rolland",
      "223": "Ntat'a Rona Mahodimong - S. Rolland",
      "224": "Naha Tsohle Bokang Morena Jehova - T. Arbousset",
      "225": "Alleluya ho Jehova - E. Casalis",
      "226": "Ho Ntate Mora Le Moya - S. Rolland",
      "227": "Ntat'a Mohau A Roriswe - S. Rolland",
      "228": "Re Boke ka Pelo - T. Arbousset",
      "229": "Kganya E Be Ho Ntate le Ho Mora - A. Mabille",
      "230": "Kganya letlotlo - E be Tsa Modimo - A. Mabille",
      "231": "Ho Eena ya ka re Sitsang - F. Coillard",
      "232": "Ho Ntate, Mora, le Moya - F. Coillard",
      "233": "Eena ea Dutseng Teroneng - F. Coillard",
      "234": "Bokang 'Mopi le 'Moloki - S. Rolland",
      "235": "Bokang Jehova, Modim'a Iseraele - E. Rolland",
      "236": "O Molemo - F. Coillard",
      "237": "Hlweko ke ya Morena - F. Coillard",
      "237A": "Ho Hotle Ho O Tlotla - S. Rolland",
      "238": "Mohau wa Morena Jesu - F. Coillard",
      "239": "Na o Hlokile Sebaka - F. Coillard",
      "240": "Mohau wa Morena Jesu - S. Rolland",
      "241": "Ea Renang ka Ho sa Feleng - S. Rolland",
      "242": "Modimo re Felehetse - A. Mabille",
      "243": "Se 'Makatsang, se Ntlholetseng - F. Coillard",
      "244": "Latelang Modisa, Modisa ea Molemo - F. Coillard",
      "245": "Nahathotheng, Moo ke Ntseng ke Lelera - E. Rolland",
      "246": "Oa Hlaha, O Jesu - E. Rolland",
      "247": "Jehova Modimo ke Nģosa Kgauhelo - E. Rolland",
      "248": "Helang, Lona ba Tepeletseng - E. Rolland",
      "249": "Ke wa'ng Basotho, Mokgosi - A. Mabille",
      "250": "Faphang Jesu ka Dithoko - F. Coillard",
      "251": "Jerusalema e Mocha - E. Mabille",
      "252": "Mpolelleng! Na Lehodimong - F. Coillard",
      "253": "Moren'a ka, ke sa Bua le Wena - A. Mabille",
      "254": "Jesu O Shwetse Batho - A. Mabille",
      "255": "Naha e Teng e Ratehang - A. Mabille",
      "256": "Rona Re Ratang Jesu - L. Duvoisin",
      "257": "Matsatsi a Ntse a Feta - A. Mabille",
      "258": "Hosanna, Hosanna - A. Mabille",
      "259": "Monghadi Wa Ka Ke Tsietswe - S. Rolland",
      "260": "Mohau wa Morena Jesu - E. Rolland",
      "261": "Morena, ka Letsatsi Lena - L. Duvoisin",
      "262": "Jesu, ke Tla ke Hlomohile - L. Duvoisin",
      "263": "E Sa Le Ho Qaleng O Nthatile - L. Duvoisin",
      "264": "Hoja ke Se Na Wena - L. Duvoisin",
      "265": "Jesu, Moren'a ka - L. Duvoisin",
      "266": "Hoja Nka Bapa le Jesu - A. Mabille",
      "267": "Jesu Rato La Hao - A. Mabille",
      "268": "Sefapanong Ke Boha - A. Maille",
      "269": "O Halalehile, Modim'o Moholo - A. Mabille",
      "270": "Ho Jesu Ke Beile - A. Mabille",
      "271": "Tlo Jesu Se Diehe - A. Mabille",
      "272": "Bolelang, Taba Tsa Jesu - A. Sello",
      "273": "Jesu Motsoalle ea Nkileng - A. Mabille",
      "274": "Moya wa ka, O Mamele Dipina - A. Mabille",
      "275": "Lemohang Rato La Jesu - A. Mabille",
      "276": "Jesu O tla Rena Hohle - A. Mabille",
      "277": "Morena, Banyadi Bana - S. Rolland",
      "278": "Dintoa Tsee Re Di Pheellang - H. Dieterlen",
      "279": "Bokang Modimo, Morena - A. Mabille",
      "280": "Kganya e Be Ho Ntate - A. Mabille",
      "281": "Ho Konyana ya Modimo - A. Mabille",
      "282": "Ho Wena Re Tlisa Dillo Tsa Rona - L. Duvoisin",
      "282A": "Re Siele Kgotso ya Hao - S. Rolland",
      "283": "Mamelang Mantswe A Matle - A. Mabille",
      "284": "Modimo O k’o Rute Dipelo Tsa Rona - A. Mabille",
      "285": "Lebitso La Jesu Hase Le Ho Rateha - L. Duvoisin",
      "286": "Raohang Masole - A. Mabille",
      "287": "Pula! Pula! Jehova - F. Ellenberger",
      "288": "Fatsheng Lena Hase Hae Ha Eso - A. Mabille",
      "289": "Ntataise, Modisa ea Molemo - A. Mabille",
      "290": "Letsatsi La Hao, Morena - A. Mabille",
      "291": "Ke Tla Tseba Joang - A. Mabille",
      "292": "Ho Phela Ho Morena Wa Ka - A. Mabille",
      "293": "Kgotso, kgotso! - A. Mabille",
      "294": "Ke Ne Ke Tla Re'ng Ha Jesu A Ka Mpotsa - A. Mabille",
      "295": "Utloa, Morutuwa Wa Morena - A. Mabille",
      "296": "Modimo o Mosa - A. Mabille",
      "297": "Ho Re Chabetse Kajeno - A. Mabille",
      "298": "Tlong Baahi Ba Lesotho - A. Mabille",
      "299": "Se Kgathaleng Bana Beso - F. Coillard",
      "300": "Ke Buletswe Phatlalatsa - F. Coillard",
      "301": "Ke Thabile, Ke Ratoa Ke Ntate - F. Coillard",
      "302": "Tsoha O Ye Tshimong - F. Coillard",
      "303": "Ea O Pate Dillo - F. Coillard",
      "304": "Jo Ke Madimabe Joang - F. Coillard",
      "305": "Batlang Le Batlisise - F. Coillard",
      "306": "Na O Tseba Modimo - F. Coillard",
      "307": "Motse Oo Re O Hlolohetsoeng - F. Coillard",
      "308": "Ke Se Ke Utloile - F. Coillard",
      "309": "Ho Fedile Ke Lehlohonolo - F. Coillard",
      "310": "Fatsheng La Bomadimabe - F. Coillard",
      "311": "Tlo Hae Tlo Hae - F. Coillard",
      "312": "Oho Mpolelleng Taba - F. Coillard",
      "313": "Tsohang, Emelang Jesu - F. Coillard",
      "314": "Tlong Ho Jesu, Le Tle Kapele - F. Coillard",
      "315": "Ha Ke Le Tjee, Ke Le Mobe - F. Coillard",
      "316": "Jesu O Nts'a Bitsa - F. Coillard",
      "317": "Ke Mang, Ke Mang Monyako - F. Coillard",
      "318": "Matshwele A Batho Bale - F. Coillard",
      "319": "Tau Di Ka Lapa - F. Coillard",
      "320": "Edisang Difahleho - F. Coillard",
      "321": "Ke O Labalabetse Hakaakang - F. Coillard",
      "322": "He, ba Nyoriloeng - F. Coillard",
      "323": "Ke Sikiloe Ke Jesu - F. Coillard",
      "324": "E, Ka Kgohlong Ya Moriti Wa Lefu - F. Coillard",
      "325": "Lefatsheng Lena La Basele - F. Coillard",
      "326": "Ho Se Ho Phethehile - F. Coillard",
      "327": "Lefifing Le Letsho-letsho - F. Coillard",
      "328": "E, ke Rongoa Ke Jesu - F. Coillard",
      "329": "Kenang Bohle, Baka Se Sa Le Teng - F. Coillard",
      "330": "Tadima Ho Jesu Wena Molahlehi - F. Coillard",
      "331": "Ke Lehlahana Feela La Morena - F. Coillard",
      "332": "Ke Mahlaku Feela-feela - F. Coillard",
      "333": "Jesu Kea Baba Kea O Llela - F. Coillard",
      "334": "Ke Fumane Bofihla - F. Coillard",
      "335": "Phallang Le Phallele - F. Coillard",
      "336": "Modimo O Re Ratile - F. Coillard",
      "337": "Thabang Le Nyakalle, Ba Lehodimo - F. Coillard",
      "338": "Ka Hlahlathela Feelleng Halelele - F. Coillard",
      "339": "Ke Bodiba Bo Bilohang - F. Coillard",
      "340": "Ha O Jala E Sa Le Meso - F. Coillard",
      "341": "Lekgolo la Dinku Kaofela - F. Coillard",
      "342": "O Mohau Wa Modimo - F. Coillard",
      "343": "Jo Sebe se sa Hlakoheng - F. Coillard",
      "344": "Lehae Le Letle ke Lane - F. Coillard",
      "345": "Ntate Lerato la Hao le Lekaakang - F. Coillard",
      "346": "Lekunutung le Morena - F. Coillard",
      "347": "Bonang, Sona O Fihlile - F. Coillard",
      "348": "Jo, Kgalefo Ya Modimo E Befile - F. Coillard",
      "349": "Utloang Utloang Ditaba - F. Coillard",
      "350": "Jo O Batlile O Dumela - F. Coillard",
      "351": "Na O Kokomalla'ng - F. Coillard",
      "352": "O o Motle Hakaakang - F. Coillard",
      "353": "Na O Hlompheha Hakaakang - F. Coillard",
      "354": "Pula Tsa Lehlohonolo - F. Coillard",
      "355": "Jehova, Mo Tsamaise - F. Coillard",
      "356": "Na Ke Bo-mang Mose Ledibohong - F. Coillard",
      "357": "Mpheng Mapheo a Tumelo - F. Coillard",
      "358": "O Nkise Qhobosheaneng - F. Coillard",
      "359": "O Lefika la Mehleng - F. Coillard",
      "360": "O Morati Ea Nthatang - F. Coillard",
      "361": "Se Mphete, Wen'a Ratehang - F. Coillard",
      "362": "Lentswe La Hao ke Lebone - F. Coillard",
      "363": "Ruri le nkgapile pelo, - F. Coillard",
      "364": "Ke Tla Ke Le Feela-feela - F. Coillard",
      "365": "Helang Chaba tsa Lefatshe - F. Coillard",
      "366": "Utloang Taba tse Molemo - F. Coillard",
      "367": "Helang Lona Dihoai tsa Morena - F. Coillard",
      "368": "Helang Utloang! Mohoo Oa Utloahala - F. Coillard",
      "369": "Butle, Butle! Bea Pelo, Ngoan'a Ka - F. Coillard",
      "370": "Ditaba Tse O Imelang - F. Coillard",
      "371": "Ba Kae Ba Kae Bakotudi - F. Coillard",
      "372": "Ke Itella Wena - F. Coillard",
      "373": "Jesu O Nts'a Mpoloka - F. Coillard",
      "374": "'Mele, Pelo, le Moya - F. Coillard",
      "375": "Le Hopotse Kae Ba Heso? - F. Coillard",
      "376": "Re Se Re Tla Ea Robala - F. Coillard",
      "377": "Utloang Lentswe Lea Tlerola - F. Coillard",
      "378": "Oho Nkutlwele Bohloko - F. Coillard",
      "379": "Ho Dula Le Ntate - F. Coillard",
      "380": "Phumola Dikgororo - F. Coillard",
      "381": "Utloang Taba e Molemo - F. Coillard",
      "382": "Jerusalema ea Phatsimang - F. Coillard",
      "383": "Jo Ho Lefifi Ntate - F. Coillard",
      "384": "Tlong O Le Tle Joale - F. Coillard",
      "385": "Le Faneng - F. Coillard",
      "386": "O Tla Nketela Neng - F. Coillard",
      "387": "Ke Tsielehile - F. Coillard",
      "388": "Baratuwa ba Jesu - F. Coillard",
      "389": "Taba tse Molemo tsa Evangedi - F. Coillard",
      "390": "Le Chabile le Chabile - F. Coillard",
      "391": "Mohlomohi Fatsheng Lena - F. Coillard",
      "392": "Moren'a Ka ea Ratehang - F. Coillard",
      "393": "Seforo Ke se Fumane - F. Coillard",
      "394": "Pholosa Ntate Pholosa - F. Coillard",
      "395": "Wena Jesu Wena Feela - F. Coillard",
      "396": "Dumela Bethel Wa Rona - F. Coillard",
      "397": "Lefifing la Mahlomola - F. Coillard",
      "398": "O Baeti ba Hlahlathang - F. Coillard",
      "399": "Ka Re Ke Tla Iponela - F. Coillard",
      "400": "E Ke Se ke Bone - F. Coillard",
      "401": "Ha ke Qala Ho Phaphama - F. Coillard",
      "402": "Na ke Ntho e Ka o Kgahlang - F. Coillard",
      "403": "Ke Bone ke Bone Tsela - F. Coillard",
      "404": "Jesu a Shoa 'me a Tsoha Bafung - F. Coillard",
      "405": "Ka Dinako Tsohle - F. Coillard",
      "406": "Lehodimong Hae le Letle - F. Coillard",
      "407": "Oa Nkalosa Ho Ntekane - F. Coillard",
      "408": "Tumelo Ke Na le Yona - F. Coillard",
      "409": "Ke tla Bona kae Tumelo - F. Coillard",
      "410": "Jo 'na Lefifi le Letsho - F. Coillard",
      "411": "Bokang Bokang 'Moloki wa Rona Jesu - F. Coillard",
      "412": "Nyakallang Bohle 'Moloki O Tlile - F. Coillard",
      "413": "E O Motle oa Rateha - F. Coillard",
      "414": "Morena Ho Etsahale - F. Coillard",
      "415": "Ho Rata Ha Hao Morena - F. Coillard",
      "416": "Jo, Lefifi Le Lekaakang - F. Coillard",
      "417": "Emmanuele Mong'a Rona - F. Coillard",
      "418": "Ke Mofero Ke Bofifi Feela - F. Coillard",
      "419": "Tshepo ya ka Feela-feela - F. Coillard",
      "420": "Sona, Marung O S'a Hlaha - F. Coillard",
      "421": "Ha ke Ne ke Itshela ka Dikgapha - F. Coillard",
      "422": "Modimo, Mong'a Lefatshe - F. Coillard",
      "423": "Ditshiu, Dinako Tsohle - F. Coillard",
      "424": "Bakgethoa, Binang Alleluya - F. Coillard",
      "425": "Lelala O Tswele Pele - F. Coillard",
      "426": "O Tla Busa, O Tla Busa - F. Coillard",
      "427": "O Modimo, Re Hloreha Hakaakang? - F. Coillard",
      "428": "Nkekeletse Ntate - F. Coillard",
      "429": "Batho Bohle Ba Merabe - F. Coillard",
      "430": "O o Tsamaye Leseding - F. Coillard",
      "431": "Na Ke Tla Bolokeha Joang - F. Coillard",
      "432": "Tsohang, Baahi Ba Lesotho - V. Ellenberger",
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
      "450": "Tla Re Yeng Ba Rategang - Circuit Rider"
    };
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(hymnViewModeProvider);
    final searchQuery = ref.watch(hymnSearchQueryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hymns = _getHymns();

    // Filter hymns based on search query
    final filteredHymns = hymns.entries.where((entry) {
      final query = searchQuery.toLowerCase();
      return entry.key.contains(query) || entry.value.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tsa Sione',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: Icon(
              viewMode == HymnViewMode.grid ? Icons.list_alt : Icons.grid_view_outlined,
              color: theme.iconTheme.color,
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (value) => ref.read(hymnSearchQueryProvider.notifier).set(value),
                decoration: InputDecoration(
                  hintText: 'Search hymn name or number...',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white24 : Colors.black26),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: viewMode == HymnViewMode.grid
                ? GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final entry = filteredHymns[index];
                      return _GridHymnItem(
                        number: entry.key,
                        title: entry.value,
                        isDark: isDark,
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHymns.length,
                    itemBuilder: (context, index) {
                      final entry = filteredHymns[index];
                      return _ListHymnItem(
                        number: entry.key,
                        title: entry.value,
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GridHymnItem extends StatelessWidget {
  final String number;
  final String title;
  final bool isDark;

  const _GridHymnItem({
    required this.number,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HymnDetailScreen(
              number: number,
              title: title,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF4DB66A),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListHymnItem extends StatelessWidget {
  final String number;
  final String title;
  final bool isDark;

  const _ListHymnItem({
    required this.number,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HymnDetailScreen(
                number: number,
                title: title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB66A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Color(0xFF4DB66A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HymnDetailScreen extends StatelessWidget {
  final String number;
  final String title;

  const HymnDetailScreen({
    super.key,
    required this.number,
    required this.title,
  });

  Future<String> _loadLyric() async {
    try {
      return await rootBundle.loadString('assets/tsa-sione/$number.txt');
    } catch (e) {
      return 'Error loading hymn: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Split title and author
    final titleParts = title.split(' - ');
    final mainTitle = titleParts[0];
    final author = titleParts.length > 1 ? titleParts[1] : '';

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
        future: _loadLyric(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4DB66A)));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load hymn content'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  mainTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.crimsonText(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4DB66A),
                  ),
                ),
                if (author.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    author,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB66A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  snapshot.data!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.crimsonText(
                    fontSize: 21,
                    height: 1.7,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
