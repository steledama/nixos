{identity, ...}: {
  # RICOH IM 550
  # Stampante multifunzione in bianco/nero di rete, LAN casa

  hardware.printers = {
    ensurePrinters = [
      {
        name = "RICOH_IM_550";
        # PPD in modalità PDF, non PostScript: la IM 550 scarta il PS di
        # foomatic (document-unprintable-error) e stampa il PDF. CUPS converte
        # in PDF ogni formato in ingresso (verificato da neve il 2026-10-16).
        deviceUri = "ipp://${identity.home.printers.im550}/ipp/print";
        model = "foomatic-db/Ricoh/PDF/Ricoh-IM_550_PDF.ppd.gz";
        description = "RICOH IM 550 (${identity.home.printers.im550})";
        location = "Casa";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "RICOH_IM_550";
  };
}
