// Modèle de données pour les médicaments
class Medicament {
  final String nom;
  final String? nomCommercial;
  final String galenique;
  final List<Indication> indications;
  final String contreIndications;
  final String surdosage;
  final String? aSavoir;

  Medicament({
    required this.nom,
    this.nomCommercial,
    required this.galenique,
    required this.indications,
    required this.contreIndications,
    required this.surdosage,
    this.aSavoir,
  });

  factory Medicament.fromJson(Map<String, dynamic> json) {
    return Medicament(
      nom: json['nom']?.toString() ?? 'Sans nom',
      nomCommercial: json['nomCommercial']?.toString(),
      galenique: json['galenique']?.toString() ?? '',
      indications: (json['indications'] as List<dynamic>?)
              ?.map((i) => Indication.fromJson(i))
              .toList() ??
          [],
      contreIndications: json['contreIndications']?.toString() ?? '',
      surdosage: json['surdosage']?.toString() ?? '',
      aSavoir: json['aSavoir']?.toString(),
    );
  }

  String get nomComplet {
    if (nomCommercial != null) {
      return '$nom ($nomCommercial)';
    }
    return nom;
  }
}

class Indication {
  final String label;
  final List<Posologie> posologies;

  Indication({
    required this.label,
    required this.posologies,
  });

  factory Indication.fromJson(Map<String, dynamic> json) {
    return Indication(
      label: json['label']?.toString() ?? 'Sans label',
      posologies: (json['posologie'] as List<dynamic>?)
              ?.map((p) => Posologie.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class Posologie {
  final String voie;
  final String? adultes; // Optionnel
  final List<DoseAdulte>? dosesAdultes; // Nouveau: tableau de doses adultes
  final String preparation;
  final List<PosologiePediatrique>? pediatrie;

  Posologie({
    required this.voie,
    this.adultes,
    this.dosesAdultes,
    required this.preparation,
    this.pediatrie,
  });

  factory Posologie.fromJson(Map<String, dynamic> json) {
    return Posologie(
      voie: json['voie']?.toString() ?? '',
      adultes: json['adultes']?.toString(),
      dosesAdultes: json['dosesAdultes'] != null
          ? (json['dosesAdultes'] as List<dynamic>)
              .map((d) => DoseAdulte.fromJson(d))
              .toList()
          : null,
      preparation: json['preparation']?.toString() ?? '',
      pediatrie: (json['pediatrie'] as List<dynamic>?)
          ?.map((p) => PosologiePediatrique.fromJson(p))
          .toList(),
    );
  }

  // Génère le texte de posologie adulte
  String getAdulteText() {
    if (adultes != null && adultes!.isNotEmpty) {
      return adultes!;
    }
    if (dosesAdultes != null && dosesAdultes!.isNotEmpty) {
      return dosesAdultes!.map((d) => d.toString()).join('\n');
    }
    return 'Non défini';
  }
}

// Nouvelle classe pour doses adultes en tableau
class DoseAdulte {
  final String? condition; // "< 60 kg", "60-80 kg", etc.
  final String dose;

  DoseAdulte({
    this.condition,
    required this.dose,
  });

  factory DoseAdulte.fromJson(Map<String, dynamic> json) {
    return DoseAdulte(
      condition: json['condition']?.toString(),
      dose: json['dose']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    if (condition != null) {
      return '$condition: $dose';
    }
    return dose;
  }
}

class PosologiePediatrique {
  final int? minIndex;
  final int? maxIndex;
  final double? minPoids; // Nouveau: tranche de poids directe
  final double? maxPoids; // Nouveau: tranche de poids directe
  final double? mgPerKg; // Devient optionnel
  final String? doseFixe; // Nouveau: dose fixe (ex: "0.15 mg")
  final List<DosePediatrique>? doses; // Nouveau: tableau de doses
  final double? maxMg;
  final double? maxMgJour;
  final String note;

  PosologiePediatrique({
    this.minIndex,
    this.maxIndex,
    this.minPoids,
    this.maxPoids,
    this.mgPerKg,
    this.doseFixe,
    this.doses,
    this.maxMg,
    this.maxMgJour,
    required this.note,
  });

  factory PosologiePediatrique.fromJson(Map<String, dynamic> json) {
    return PosologiePediatrique(
      minIndex: json['minIndex'] as int?,
      maxIndex: json['maxIndex'] as int?,
      minPoids: json['minPoids'] != null ? (json['minPoids'] as num).toDouble() : null,
      maxPoids: json['maxPoids'] != null ? (json['maxPoids'] as num).toDouble() : null,
      mgPerKg: json['mgPerKg'] != null ? (json['mgPerKg'] as num).toDouble() : null,
      doseFixe: json['doseFixe']?.toString(),
      doses: json['doses'] != null
          ? (json['doses'] as List<dynamic>)
              .map((d) => DosePediatrique.fromJson(d))
              .toList()
          : null,
      maxMg: json['maxMg'] != null ? (json['maxMg'] as num).toDouble() : null,
      maxMgJour: json['maxMgJour'] != null ? (json['maxMgJour'] as num).toDouble() : null,
      note: json['note']?.toString() ?? '',
    );
  }

  // Vérifie si cette posologie s'applique à l'âge donné
  bool appliqueAAge(int ageIndex) {
    if (minIndex != null && maxIndex != null) {
      return ageIndex >= minIndex! && ageIndex <= maxIndex!;
    }
    return true;
  }

  // Vérifie si cette posologie s'applique au poids donné
  bool appliqueAPoids(double poids) {
    if (minPoids != null && poids < minPoids!) return false;
    if (maxPoids != null && poids > maxPoids!) return false;
    return true;
  }

  // Calcule la dose pour un poids donné
  String calculerDose(double poids) {
    String result = '';

    // Cas 1: Dose fixe
    if (doseFixe != null) {
      result = "Dose: $doseFixe\n";
    }
    // Cas 2: Tableau de doses
    else if (doses != null && doses!.isNotEmpty) {
      result = "Doses possibles:\n";
      for (var dose in doses!) {
        if (dose.appliqueAPoids(poids)) {
          result += "• ${dose.toString()}\n";
        }
      }
    }
    // Cas 3: Calcul avec mg/kg
    else if (mgPerKg != null) {
      double doseParPrise = mgPerKg! * poids;
      
      String doseStr;
      if (doseParPrise < 1) {
        doseStr = "${(doseParPrise * 1000).toStringAsFixed(0)} µg (${doseParPrise.toStringAsFixed(2)} mg)";
      } else {
        doseStr = "${doseParPrise.toStringAsFixed(2)} mg";
      }
      
      result = "Dose: ${mgPerKg!.toStringAsFixed(2)} mg/kg\n"
               "Soit $doseStr par prise\n";
      
      // Max par prise
      if (maxMg != null) {
        String maxPriseStr;
        if (maxMg! < 1) {
          maxPriseStr = "${(maxMg! * 1000).toStringAsFixed(0)} µg (${maxMg!.toStringAsFixed(2)} mg)";
        } else {
          maxPriseStr = "${maxMg!.toStringAsFixed(2)} mg";
        }
        result += "Max par prise: $maxPriseStr\n";
      }
      
      // Max journalier
      if (maxMgJour != null) {
        double maxParJour = maxMgJour! * poids;
        String maxJourStr;
        if (maxParJour < 1) {
          maxJourStr = "${(maxParJour * 1000).toStringAsFixed(0)} µg (${maxParJour.toStringAsFixed(2)} mg)";
        } else {
          maxJourStr = "${maxParJour.toStringAsFixed(2)} mg";
        }
        result += "Max/jour: $maxJourStr (${maxMgJour!.toStringAsFixed(2)} mg/kg/j)\n";
      }
    }
    
    result += "Note: $note";
    return result;
  }
}

// Nouvelle classe pour tableau de doses pédiatriques
class DosePediatrique {
  final double? minPoids;
  final double? maxPoids;
  final String dose;
  final String? description;

  DosePediatrique({
    this.minPoids,
    this.maxPoids,
    required this.dose,
    this.description,
  });

  factory DosePediatrique.fromJson(Map<String, dynamic> json) {
    return DosePediatrique(
      minPoids: json['minPoids'] != null ? (json['minPoids'] as num).toDouble() : null,
      maxPoids: json['maxPoids'] != null ? (json['maxPoids'] as num).toDouble() : null,
      dose: json['dose']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  bool appliqueAPoids(double poids) {
    if (minPoids != null && poids < minPoids!) return false;
    if (maxPoids != null && poids > maxPoids!) return false;
    return true;
  }

  @override
  String toString() {
    String result = '';
    if (minPoids != null || maxPoids != null) {
      if (minPoids != null && maxPoids != null) {
        result = '${minPoids!.toStringAsFixed(0)}-${maxPoids!.toStringAsFixed(0)} kg: ';
      } else if (minPoids != null) {
        result = '≥ ${minPoids!.toStringAsFixed(0)} kg: ';
      } else if (maxPoids != null) {
        result = '< ${maxPoids!.toStringAsFixed(0)} kg: ';
      }
    }
    result += dose;
    if (description != null) {
      result += ' ($description)';
    }
    return result;
  }
}