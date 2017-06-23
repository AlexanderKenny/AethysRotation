--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, addonTable = ...;
  -- AethysRotation
  local AR = AethysRotation;


--- ============================ CONTENT ============================
  -- All settings here should be moved into the GUI someday.
  AR.GUISettings.APL.Warlock = {
    Commons = {
      -- {Display GCD as OffGCD, ForceReturn}
      GCDasOffGCD = {
        -- Abilities

      },
      -- {Display OffGCD as OffGCD, ForceReturn}
      OffGCDasOffGCD = {
        -- Racials
        ArcaneTorrent = {true, false},
        Berserking = {true, false},
        BloodFury = {true, false},
        -- Abilities
        
      }
    },
    Destruction = {
      -- {Display GCD as OffGCD, ForceReturn}
      GCDasOffGCD = {
        -- Abilities
        DemonicPower = {true, false},
        SummonDoomGuard = {true, false},
        SummonInfernal = {true, false},
        SummonImp = {true, false},
        GrimoireOfSacrifice = {true, false},
        GrimoireImp = {true, false},
        LifeTap = {true, false},
	DimensionalRift = {true, false}
      },
      -- {Display OffGCD as OffGCD, ForceReturn}
      OffGCDasOffGCD = {
        -- Racials
        
        -- Abilities
        SoulHarvest = {true, false},
      }
    },
    Demonology = {
      -- {Display GCD as OffGCD, ForceReturn}
      GCDasOffGCD = {
        -- Abilities
        DemonicPower = {true, false},
        SummonDoomGuard = {true, false},
        SummonInfernal = {true, false},
        SummonImp = {true, false},
        GrimoireOfSacrifice = {true, false},
        GrimoireImp = {true, false},
        LifeTap = {true, false}
      },
      -- {Display OffGCD as OffGCD, ForceReturn}
      OffGCDasOffGCD = {
        -- Racials
        
        -- Abilities
        
      }
    }
  };
