class SeriesUtils {
  static Map<int, String> getSeriesData(String language) {
    if (language == 'or') {
      return {
        0: "TATAISO EA SEHAPI SA MOEA",
        1: "KHOLISEHO EA PHOLOHO",
        2: "THAPELO",
        3: "BIBELE LE OENA",
        4: "MOLEKO",
        5: "TLHORISO",
        6: "HO TIISETSA TUMELONG",
        7: "LELAPA LA NNETE",
        8: "BOLELLA METSOALLE EA HAO",
      };
    }
    return {
      0: "Guides to convert series",
      1: "Assurance of salvation",
      2: "Prayer",
      3: "Bible and you",
      4: "Temptation",
      5: "Persecution",
      6: "Steadfastness",
      7: "True Family",
      8: "Tell your friends",
    };
  }
}
