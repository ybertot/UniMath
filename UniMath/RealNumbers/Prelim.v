(** * Additionals theorems and definitions *)

Require Export UniMath.Topology.Prelim.

Unset Automatic Introduction. (* This line has to be removed for the file to compile with Coq8.2 *)

(** ** for RationalNumbers.v *)

Require Export UniMath.Foundations.NumberSystems.RationalNumbers.
Require Export UniMath.Foundations.Algebra.Archimedean.
Require Export UniMath.Foundations.Algebra.Lattice.

Open Scope hq_scope.

Notation "x <= y" := (hqleh x y) : hq_scope.
Notation "x >= y" := (hqgeh x y) : hq_scope.
Notation "x < y" := (hqlth x y) : hq_scope.
Notation "x > y" := (hqgth x y) : hq_scope.
Notation "/ x" := (hqmultinv x) : hq_scope.
Notation "x / y" := (hqdiv x y) : hq_scope.
Notation "2" := (hztohq (nattohz 2)) : hq_scope.

Lemma hzone_neg_hzzero : neg (1%hz = 0%hz).
Proof.
  confirm_not_equal isdeceqhz.
Qed.

Definition one_intdomnonzerosubmonoid : intdomnonzerosubmonoid hzintdom.
Proof.
  exists 1%hz ; simpl.
  exact hzone_neg_hzzero.
Defined.

Opaque hz.

Lemma hq2eq1plus1 : 2 = 1 + 1.
Proof.
  confirm_equal isdeceqhq.
Qed.

Lemma hq2_gt0 : 2 > 0.
Proof.
  confirm_yes hqgthdec 2 0.
Qed.

Lemma hq1_gt0 : 1 > 0.
Proof.
  confirm_yes hqgthdec 1 0.
Qed.

Lemma hq1ge0 : (0 <= 1)%hq.
Proof.
  confirm_yes hqlehdec 0 1.
Qed.

Lemma hqgth_hqneq :
  Π x y : hq, x > y -> hqneq x y.
Proof.
  intros x y Hlt Heq.
  rewrite Heq in Hlt.
  now apply isirreflhqgth with y.
Qed.

Lemma hqldistr :
  Π x y z, x * (y + z) = x * y + x * z.
Proof.
  intros x y z.
  now apply rngldistr.
Qed.

Lemma hqmult2r :
  Π x : hq, x * 2 = x + x.
Proof.
  intros x.
  now rewrite hq2eq1plus1, hqldistr, (hqmultr1 x).
Qed.

Lemma hqplusdiv2 : Π x : hq, x = (x + x) / 2.
  intros x.
  apply hqmultrcan with 2.
  now apply hqgth_hqneq, hq2_gt0.
  unfold hqdiv.
  rewrite hqmultassoc.
  rewrite (hqislinvmultinv 2).
  2: now apply hqgth_hqneq, hq2_gt0.
  rewrite (hqmultr1 (x + x)).
  apply hqmult2r.
Qed.

Lemma hqlth_between :
  Π x y : hq, x < y -> total2 (fun z => dirprod (x < z) (z < y)).
Proof.
  assert (H0 : / 2 > 0).
  { apply hqgthandmultlinv with 2.
    apply hq2_gt0.
    rewrite hqisrinvmultinv, hqmultx0.
    now apply hq1_gt0.
    now apply hqgth_hqneq, hq2_gt0.
  }
  intros x y Hlt.
  exists ((x + y) / 2).
  split.
  - pattern x at 1.
    rewrite (hqplusdiv2 x).
    unfold hqdiv.
    apply (hqlthandmultr _ _ (/ 2)).
    exact H0.
    now apply (hqlthandplusl _ _ x Hlt).
  - pattern y at 2.
    rewrite (hqplusdiv2 y).
    unfold hqdiv.
    apply (hqlthandmultr _ _ (/ 2)).
    exact H0.
    now apply (hqlthandplusr _ _ y Hlt).
Qed.

Lemma hq0lehandplus:
  Π n m : hq,
    0 <= n -> 0 <= m -> 0 <= (n + m).
Proof.
  intros n m Hn Hm.
  eapply istranshqleh, hqlehandplusl, Hm.
  now rewrite hqplusr0.
Qed.

Lemma hq0lehandmult:
  Π n m : hq, 0 <= n -> 0 <= m -> 0 <= n * m.
Proof.
  intros n m.
  exact hqmultgeh0geh0.
Qed.

Lemma hq0leminus :
  Π r q : hq, r <= q -> 0 <= q - r.
Proof.
  intros r q Hr.
  apply hqlehandplusrinv with r.
  unfold hqminus.
  rewrite hqplusassoc, hqlminus.
  now rewrite hqplusl0, hqplusr0.
Qed.

Lemma hqinv_gt0 (x : hq) : 0 < x → 0 < / x.
Proof.
  unfold hqlth.
  intros x Hx.
  apply hqgthandmultlinv with x.
  - exact Hx.
  - rewrite hqmultx0.
    rewrite hqisrinvmultinv.
    + exact hq1_gt0.
    + apply hqgth_hqneq.
      exact Hx.
Qed.

Lemma hqgth_opp :
  Π x y : hq, x > y → - y > - x.
Proof.
  intros x y Hxy.
  apply hqgthandpluslinv with y.
  change (y - y > y + - x).
  rewrite hqrminus.
  apply hqgthandplusrinv with x.
  rewrite hqplusassoc, hqlminus, hqplusl0, hqplusr0.
  exact Hxy.
Qed.
Lemma hqgth_opp' :
  Π x y : hq, - x > - y → y > x.
Proof.
  intros x y Hxy.
  apply hqgth_opp in Hxy.
  rewrite !(grinvinv hq) in Hxy.
  exact Hxy.
Qed.

Lemma hztohqandleh':
  Π n m : hz, (hztohq n <= hztohq m)%hq → hzleh n m.
Proof.
  intros n m Hle Hlt.
  simple refine (Hle _).
  apply hztohqandgth.
  exact Hlt.
Qed.
Lemma hztohqandlth':
  Π n m : hz, (hztohq n < hztohq m)%hq -> hzlth n m.
Proof.
  intros n m Hlt.
  apply neghzgehtolth.
  intro Hle.
  apply hztohqandgeh in Hle.
  apply hqgehtoneghqlth in Hle.
  apply Hle.
  exact Hlt.
Qed.

(** ** nat is a lattice *)

Lemma min_id :
  Π n : nat, min n n = n.
Proof.
  intros n.
  induction n as [ | n IHn].
  - reflexivity.
  - change (S (min n n) = S n).
    apply maponpaths, IHn.
Qed.
Lemma max_id :
  Π n : nat, max n n = n.
Proof.
  intros n.
  induction n as [ | n IHn].
  - reflexivity.
  - change (S (max n n) = S n).
    apply maponpaths, IHn.
Qed.

Lemma isassoc_min :
  isassoc (X := hSetpair nat isasetnat) min.
Proof.
  intros n.
  induction n as [ | n IHn].
  - intros m k.
    reflexivity.
  - intros m.
    induction m as [ | m _].
    + intros k.
      reflexivity.
    + intros k.
      induction k as [ | k _].
      * reflexivity.
      * change (S (min (min n m) k) = S (min n (min m k))).
        apply maponpaths, IHn.
Qed.
Lemma iscomm_min :
  iscomm (X := hSetpair nat isasetnat) min.
Proof.
  intros n.
  induction n as [ | n IHn].
  - intros m.
    induction m as [ | m _].
    + reflexivity.
    + reflexivity.
  - intros m.
    induction m as [ | m _].
    + reflexivity.
    + change (S (min n m) = S (min m n)).
      apply maponpaths, IHn.
Qed.

Lemma isassoc_max :
  isassoc (X := hSetpair nat isasetnat) max.
Proof.
  intros n.
  induction n as [ | n IHn].
  - intros m k.
    reflexivity.
  - intros m.
    induction m as [ | m _].
    + intros k.
      reflexivity.
    + intros k.
      induction k as [ | k _].
      * reflexivity.
      * change (S (max (max n m) k) = S (max n (max m k))).
        apply maponpaths, IHn.
Qed.
Lemma iscomm_max :
  iscomm (X := hSetpair nat isasetnat) max.
Proof.
  intros n.
  induction n as [ | n IHn].
  - intros m.
    induction m as [ | m _].
    + reflexivity.
    + reflexivity.
  - intros m.
    induction m as [ | m _].
    + reflexivity.
    + change (S (max n m) = S (max m n)).
      apply maponpaths, IHn.
Qed.
Lemma isabsorb_min_max :
  Π n m : nat, min n (max n m) = n.
Proof.
  intros n.
  induction n as [ | n IHn].
  - intros m.
    reflexivity.
  - intros m.
    induction m as [ | m _].
    + change (S (min n n) = S n).
      apply maponpaths, min_id.
    + change (S (min n (max n m)) = S n).
      apply maponpaths, IHn.
Qed.
Lemma isabsorb_max_min :
  Π n m : nat, max n (min n m) = n.
Proof.
  intros n.
  induction n as [ | n IHn].
  - intros m.
    reflexivity.
  - intros m.
    induction m as [ | m _].
    + reflexivity.
    + change (S (max n (min n m)) = S n).
      apply maponpaths, IHn.
Qed.

Lemma islatticeop_nat : islatticeop (X := hSetpair nat isasetnat) min max.
Proof.
  repeat split.
  - exact isassoc_min.
  - exact iscomm_min.
  - exact isassoc_max.
  - exact iscomm_max.
  - exact isabsorb_min_max.
  - exact isabsorb_max_min.
Qed.

Definition islattice_nat : islatticedec (natcommrig).
Proof.
  exists (min ,, max ,, islatticeop_nat).
  split.
  - intros n.
    induction n as [ | n IHn].
    + intros m.
      apply hinhpr, ii1.
      reflexivity.
    + intros m.
      induction m as [ | m _].
      * apply hinhpr, ii2.
        reflexivity.
      * generalize (IHn m).
        apply hinhfun, sumofmaps ; intros H.
        left ; simpl.
        apply maponpaths, H.
        right ; simpl.
        apply maponpaths, H.
  - intros n.
    induction n as [ | n IHn].
    + intros m.
      apply ii1.
      reflexivity.
    + intros m.
      induction m as [ | m _].
      * apply ii2.
        apply negpaths0sx.
      * generalize (IHn m).
        apply sumofmaps ; intros H.
        left ; simpl.
        apply maponpaths, H.
        right ; simpl.
        apply noeqinjS, H.
Defined.

Lemma Llenat_correct :
  Π n m, n ≤ m <-> Lle islattice_nat n m.
Proof.
  intros n m.
  split.
  - revert m.
    induction n as [ | n IHn].
    + intros m H.
      reflexivity.
    + intros m.
      induction m as [ | m _].
      * change (false = true → O = S n).
        intros H.
        apply fromempty, nopathsfalsetotrue, H.
      * change (n ≤ m → S (min n m) = S n).
        intros H.
        apply maponpaths, IHn, H.
  - revert m.
    induction n as [ | n IHn].
    + intros m H.
      reflexivity.
    + intros m.
      induction m as [ | m _].
      * change (O = S n → false = true).
        intros H.
        apply fromempty, (negpaths0sx n), H.
      * change (S (min n m) = S n → n ≤ m).
        intros H.
        apply IHn.
        apply invmaponpathsS, H.
Qed.

Lemma isrdistr_natmin_plus :
  isrdistr (X := natcommrig) min Nat.add.
Proof.
  intros n ;
  induction n as [ | n IHn].
  - simpl.
    intros m k.
    apply pathsinv0, (Lmin_le_eq_l islattice_nat).
    apply Llenat_correct.
    apply natlehmplusnm.
  - intros m ; induction m as [ | m _].
    + clear ; intros k.
      change (k = Nat.min (S n + k) k).
      apply pathsinv0, (Lmin_le_eq_r islattice_nat).
      apply Llenat_correct.
      apply natlehmplusnm.
    + simpl ; intros k.
      apply maponpaths, IHn.
Qed.
Lemma isrdistr_natmax_plus :
  isrdistr (X := natcommrig) max Nat.add.
Proof.
  intros n ;
  induction n as [ | n IHn].
  - simpl.
    intros m k.
    apply pathsinv0, (Lmax_le_eq_r islattice_nat).
    apply Llenat_correct.
    apply natlehmplusnm.
  - intros m ; induction m as [ | m _].
    + clear ; intros k.
      change (S n + k = Nat.max (S n + k) k)%nat.
      apply pathsinv0, (Lmax_le_eq_l islattice_nat).
      apply Llenat_correct.
      apply natlehmplusnm.
    + simpl ; intros k.
      apply maponpaths, IHn.
Qed.

(** ** hz is a lattice *)

Lemma islattice_hz : islatticedec hz.
Proof.
  simple refine (abgrdiff_islatticedec _ _ _ _).
  apply islattice_nat.
  intros x y z ; apply natplusrcan.
  apply isrdistr_natmin_plus.
  apply isrdistr_natmax_plus.
Defined.

Definition hzmin : binop hz := Lmin islattice_hz.
Definition hzmax : binop hz := Lmax islattice_hz.

Lemma Llehz_correct :
  Π n m, hzleh n m <-> Lle islattice_hz n m.
Proof.
  intros n m.
  generalize (pr1 (pr2 n)) (pr1 (pr2 m)).
  apply hinhuniv2'.
  - apply isapropdirprod ;
    apply isapropimpl, propproperty.
  - intros n' m'.
    rewrite <- (setquotl0 _ n n'), <- (setquotl0 _ m m').
    split ; intros H.
    + apply abgrdiff_Lle.
      unfold abgrdiffrel, quotrel.
      rewrite setquotuniv2comm.
      apply hinhpr ; exists O.
      apply Llenat_correct.
      apply negnatgthtoleh ; intro H0 ; apply H.
      unfold hzgth, rigtorngrel, abgrdiffrel, quotrel.
      rewrite setquotuniv2comm.
      apply hinhpr ; exists O.
      exact H0.
    + generalize (pr2 (abgrdiff_Lle _ _ _ _ _ _) H) ; clear H.
      unfold abgrdiffrel, quotrel.
      rewrite setquotuniv2comm.
      apply hinhuniv ; intros H H0.
      unfold hzgth, rigtorngrel, abgrdiffrel, quotrel in H0.
      rewrite setquotuniv2comm in H0.
      refine (hinhuniv' _ _ H0) ; clear H0.
      apply isapropempty.
      intros H0.
      refine (natgthnegleh _ _).
      apply (pr2 H0).
      apply natlehandplusr.
      apply (natlehandplusrinv _ _ (pr1 H)).
      apply_pr2 Llenat_correct.
      apply (pr2 H).
Qed.

Lemma Llehz_dec :
  Π x y : hz, Lle islattice_hz x y ⨿ Lle islattice_hz y x.
Proof.
  intros x y.
  induction (hzgthorleh x y) as [H | H].
  - apply ii2, Llehz_correct.
    apply hzlthtoleh.
    exact H.
  - apply ii1, Llehz_correct.
    apply H.
Qed.

Lemma hzmin_case_strong :
  Π (P : hz → UU) (x y : hz),
  (hzleh x y → P x) → (hzleh y x → P y) → P (hzmin x y).
Proof.
  intros P x y Hx Hy.
  induction (Llehz_dec x y) as [H | H].
  - change (P (Lmin islattice_hz x y)).
    rewrite H.
    apply Hx.
    apply_pr2 Llehz_correct.
    apply H.
  - change (P (Lmin islattice_hz x y)).
    rewrite iscomm_Lmin, H.
    apply Hy.
    apply_pr2 Llehz_correct.
    apply H.
Qed.
Lemma hzmin_case :
  Π (P : hz → UU) (x y : hz),
  P x → P y → P (hzmin x y).
Proof.
  intros P x y Hx Hy.
  now apply hzmin_case_strong.
Qed.

Lemma hzlehopp :
  Π x y : hz, hzleh y x → (hzleh (- x) (- y))%hz.
Proof.
  intros x y H.
  apply hzlehandplusrinv with y.
  rewrite hzlminus, hzpluscomm.
  apply hzlehandplusrinv with x.
  rewrite hzplusassoc, hzlminus.
  rewrite hzplusl0, hzplusr0.
  exact H.
Qed.

Lemma hzminopp_opphzmax :
  Π x y : hz, hzmin (- x)%hz (- y)%hz = (- hzmax x y)%hz.
Proof.
  intros x y.
  change (hProppair (Lmin islattice_hz (- x)%hz (- y)%hz = (- Lmax islattice_hz x y)%hz) (isasethz _ _)).
  apply (Lmin_case_strong _ (λ z, hProppair (z = _) (isasethz z _))) ; intros Hmin ;
  apply (Lmax_case_strong _ (λ z, hProppair (_ = - z)%hz (isasethz _ (- z)%hz))) ; intros Hmax.
  - reflexivity.
  - apply isantisymmhzleh.
    + apply_pr2 Llehz_correct.
      exact Hmin.
    + apply hzlehopp.
      apply_pr2 Llehz_correct.
      exact Hmax.
  - apply isantisymmhzleh.
    + apply_pr2 Llehz_correct.
      exact Hmin.
    + apply hzlehopp.
      apply_pr2 Llehz_correct.
      exact Hmax.
  - reflexivity.
Qed.

Lemma hzoppopp :
  Π x : hz, (- (- x))%hz = x.
Proof.
  apply (grinvinv hz).
Qed.

Lemma hzmax_case_strong :
  Π (P : hz → UU) (x y : hz),
  (hzleh y x → P x) → (hzleh x y → P y) → P (hzmax x y).
Proof.
  intros P x y Hx Hy.
  rewrite <- (hzoppopp (hzmax x y)).
  rewrite <- hzminopp_opphzmax.
  apply hzmin_case_strong ; intros H.
  - rewrite hzoppopp.
    apply Hx.
    apply hzlehopp in H.
    rewrite 2!hzoppopp in H.
    apply H.
  - rewrite hzoppopp.
    apply Hy.
    apply hzlehopp in H.
    rewrite 2!hzoppopp in H.
    apply H.
Qed.
Lemma hzmax_case :
  Π (P : hz → UU) (x y : hz),
  P x → P y → P (hzmax x y).
Proof.
  intros P x y Hx Hy.
  now apply hzmax_case_strong.
Qed.

Lemma issubrdistr_hzmin_hzmult :
  Π (x y k : hz),
  hzgth k 0%hz →
  (hzmin x y * k)%hz =
  hzmin (x * k)%hz (y * k)%hz.
Proof.
  intros x y k Hk.
  refine (hzmin_case_strong _ _ _ _ _) ; intros H ;
  refine (hzmin_case_strong (λ z : hz, (z * _)%hz = _) _ _ _ _) ; intros H0.
  + reflexivity.
  + apply (isantisymmhzleh).
    * apply hzlehandmultr.
      apply Hk.
      exact H0.
    * exact H.
  + apply (isantisymmhzleh).
    * apply hzlehandmultr.
      apply Hk.
      exact H0.
    * exact H.
  + reflexivity.
Qed.
Lemma issubrdistr_hzmax_hzmult :
  Π (x y k : hz),
  hzgth k 0%hz →
  (hzmax x y * k)%hz =
  hzmax (x * k)%hz (y * k)%hz.
Proof.
  intros x y k Hk.
  refine (hzmax_case_strong _ _ _ _ _) ; intros H ;
  refine (hzmax_case_strong (λ z : hz, (z * _)%hz = _) _ _ _ _) ; intros H0.
  + reflexivity.
  + apply (isantisymmhzleh).
    * exact H.
    * apply hzlehandmultr.
      apply Hk.
      exact H0.
  + apply (isantisymmhzleh).
    * exact H.
    * apply hzlehandmultr.
      apply Hk.
      exact H0.
  + reflexivity.
Qed.

(** ** hq is a lattice *)

Lemma islattice_hq : islattice hq.
Proof.
  simple refine (fldfrac_islattice _ _ _ _ _ _ _ _ _ _).
  - apply hzgth.
  - apply isplushrelhzgth.
  - apply isrngmulthzgth.
  - apply (ct (hzgth, isdecrelhzgth, 1%hz, 0%hz)).
  - intros n.
    apply isirreflhzgth.
  - intros n m.
    apply hzneqchoice.
  - apply (pr1 islattice_hz).
  - intros x y k.
    induction k as [k Hk].
    simpl in Hk.
    change (hzmin x y * k = hzmin (x * k) (y * k))%hz.
    apply (issubrdistr_hzmin_hzmult x y k Hk).
  - intros x y k.
    induction k as [k Hk].
    simpl in Hk.
    change (hzmax x y * k = hzmax (x * k) (y * k))%hz.
    apply (issubrdistr_hzmax_hzmult x y k Hk).
Defined.

Definition hqmin : binop hq :=
  Lmin islattice_hq.
Definition hqmax : binop hq :=
  Lmax islattice_hq.

Lemma Llehq_correct :
  Π n m : hq, n <= m <-> Lle islattice_hq n m.
Proof.
  simple refine (setquotuniv2prop _ (λ _ _, _ ,, _) _).
  - apply isapropdirprod ;
    apply isapropimpl, propproperty.
  - intros n m.
    split ; intros H.
    + change (hqmin
                (setquotpr (eqrelcommrngfrac hzintdom (intdomnonzerosubmonoid hzintdom)) n)
                (setquotpr (eqrelcommrngfrac hzintdom (intdomnonzerosubmonoid hzintdom)) m) =
              (setquotpr (eqrelcommrngfrac hzintdom (intdomnonzerosubmonoid hzintdom)) n)).
      unfold abgrdiffrel, quotrel.
      rewrite setquotuniv2comm.
      apply hinhpr ; exists O.
      apply Llenat_correct.
      apply negnatgthtoleh ; intro H0 ; apply H.
      unfold hzgth, rigtorngrel, abgrdiffrel, quotrel.
      rewrite setquotuniv2comm.
      apply hinhpr ; exists O.
      exact H0.
    + generalize (pr2 (abgrdiff_Lle _ _ _ _ _ _) H) ; clear H.
      unfold abgrdiffrel, quotrel.
      rewrite setquotuniv2comm.
      apply hinhuniv ; intros H H0.
      unfold hzgth, rigtorngrel, abgrdiffrel, quotrel in H0.
      rewrite setquotuniv2comm in H0.
      refine (hinhuniv' _ _ H0) ; clear H0.
      apply isapropempty.
      intros H0.
      refine (natgthnegleh _ _).
      apply (pr2 H0).
      apply natlehandplusr.
      apply (natlehandplusrinv _ _ (pr1 H)).
      apply_pr2 Llenat_correct.
      apply (pr2 H).
Qed.

Lemma Llehz_dec :
  Π x y : hz, Lle islattice_hz x y ⨿ Lle islattice_hz y x.
Proof.
  intros x y.
  induction (hzgthorleh x y) as [H | H].
  - apply ii2, Llehz_correct.
    apply hzlthtoleh.
    exact H.
  - apply ii1, Llehz_correct.
    apply H.
Qed.

Lemma hzmin_case_strong :
  Π (P : hz → UU) (x y : hz),
  (hzleh x y → P x) → (hzleh y x → P y) → P (hzmin x y).
Proof.
  intros P x y Hx Hy.
  induction (Llehz_dec x y) as [H | H].
  - change (P (Lmin islattice_hz x y)).
    rewrite H.
    apply Hx.
    apply_pr2 Llehz_correct.
    apply H.
  - change (P (Lmin islattice_hz x y)).
    rewrite iscomm_Lmin, H.
    apply Hy.
    apply_pr2 Llehz_correct.
    apply H.
Qed.
Lemma hzmin_case :
  Π (P : hz → UU) (x y : hz),
  P x → P y → P (hzmin x y).
Proof.
  intros P x y Hx Hy.
  now apply hzmin_case_strong.
Qed.

Lemma hzlehopp :
  Π x y : hz, hzleh y x → (hzleh (- x) (- y))%hz.
Proof.
  intros x y H.
  apply hzlehandplusrinv with y.
  rewrite hzlminus, hzpluscomm.
  apply hzlehandplusrinv with x.
  rewrite hzplusassoc, hzlminus.
  rewrite hzplusl0, hzplusr0.
  exact H.
Qed.

Lemma hzminopp_opphzmax :
  Π x y : hz, hzmin (- x)%hz (- y)%hz = (- hzmax x y)%hz.
Proof.
  intros x y.
  change (hProppair (Lmin islattice_hz (- x)%hz (- y)%hz = (- Lmax islattice_hz x y)%hz) (isasethz _ _)).
  apply (Lmin_case_strong _ (λ z, hProppair (z = _) (isasethz z _))) ; intros Hmin ;
  apply (Lmax_case_strong _ (λ z, hProppair (_ = - z)%hz (isasethz _ (- z)%hz))) ; intros Hmax.
  - reflexivity.
  - apply isantisymmhzleh.
    + apply_pr2 Llehz_correct.
      exact Hmin.
    + apply hzlehopp.
      apply_pr2 Llehz_correct.
      exact Hmax.
  - apply isantisymmhzleh.
    + apply_pr2 Llehz_correct.
      exact Hmin.
    + apply hzlehopp.
      apply_pr2 Llehz_correct.
      exact Hmax.
  - reflexivity.
Qed.

Lemma hzoppopp :
  Π x : hz, (- (- x))%hz = x.
Proof.
  apply (grinvinv hz).
Qed.

Lemma hzmax_case_strong :
  Π (P : hz → UU) (x y : hz),
  (hzleh y x → P x) → (hzleh x y → P y) → P (hzmax x y).
Proof.
  intros P x y Hx Hy.
  rewrite <- (hzoppopp (hzmax x y)).
  rewrite <- hzminopp_opphzmax.
  apply hzmin_case_strong ; intros H.
  - rewrite hzoppopp.
    apply Hx.
    apply hzlehopp in H.
    rewrite 2!hzoppopp in H.
    apply H.
  - rewrite hzoppopp.
    apply Hy.
    apply hzlehopp in H.
    rewrite 2!hzoppopp in H.
    apply H.
Qed.
Lemma hzmax_case :
  Π (P : hz → UU) (x y : hz),
  P x → P y → P (hzmax x y).
Proof.
  intros P x y Hx Hy.
  now apply hzmax_case_strong.
Qed.


Lemma hqmaxopp_opphqmin :
  Π x y : hq, hqmax (- x) (- y) = - hqmin x y.
Proof.
  intros x y.
  apply hqmax_case_strong ; intros Hxy ;
  apply hqmin_case_strong ; intros Hxy'.
  - reflexivity.
  - apply isantisymmhqleh.
    + apply neghqgthtoleh.
      intros H.
      apply Hxy', hqgth_opp'.
      exact H.
    + exact Hxy.
  - apply isantisymmhqleh.
    + apply neghqgthtoleh.
      intros H.
      apply Hxy', hqgth_opp'.
      exact H.
    + exact Hxy.
  - reflexivity.
Qed.

Lemma isassoc_hqmin : isassoc hqmin.
Proof.
  intros x y z.
  unfold hqmin.
  induction (hqgthorleh x y) as [Hxy | Hxy].
  - change (sumofmaps (λ _ : x > y, y) (λ _ : x <= y, x) (ii1 Hxy)) with y.
    induction (hqgthorleh y z) as [Hyz | Hyz].
    + change (sumofmaps (λ _ : y > z, z) (λ _ : y <= z, y) (ii1 Hyz)) with z.
      induction (hqgthorleh x z) as [Hxz | Hxz].
      * reflexivity.
      * apply fromempty.
        revert Hxz.
        apply hqgthtoneghqleh.
        apply istranshqgth with y.
        exact Hxy.
        exact Hyz.
    + change (sumofmaps (λ _ : y > z, z) (λ _ : y <= z, y) (ii2 Hyz)) with y.
      induction (hqgthorleh x y) as [Hxy' | Hxy'].
      reflexivity.
      apply fromempty.
      revert Hxy'.
      apply hqgthtoneghqleh.
      exact Hxy.
  - change (sumofmaps (λ _ : x > y, y) (λ _ : x <= y, x) (ii2 Hxy)) with x.
    induction (hqgthorleh y z) as [Hyz | Hyz].
    + change (sumofmaps (λ _ : y > z, z) (λ _ : y <= z, y) (ii1 Hyz)) with z.
      reflexivity.
    + change (sumofmaps (λ _ : y > z, z) (λ _ : y <= z, y) (ii2 Hyz)) with y.
      induction (hqgthorleh x z) as [Hxz | Hxz].
      * apply fromempty.
        revert Hxz.
        apply (hqlehtoneghqgth x z).
        apply istranshqleh with y.
        exact Hxy.
        exact Hyz.
      * induction (hqgthorleh x y) as [Hxy' | Hxy'].
        apply fromempty.
        revert Hxy'.
        apply (hqlehtoneghqgth x y).
        exact Hxy.
        reflexivity.
Qed.
Lemma iscomm_hqmin : iscomm hqmin.
Proof.
  intros x y.
  unfold hqmin.
  induction (hqgthorleh x y) as [Hxy | Hxy] ;
    induction (hqgthorleh y x) as [Hxy' | Hxy'].
  - apply fromempty.
    revert Hxy'.
    apply (hqlehtoneghqgth y x).
    apply hqlthtoleh.
    exact Hxy.
  - reflexivity.
  - reflexivity.
  - change (x = y).
    apply isantisymmhqleh.
    + exact Hxy.
    + exact Hxy'.
Qed.
Lemma isassoc_hqmax : isassoc hqmax.
Proof.
  intros x y z.
  rewrite <- (grinvinv hq x), <- (grinvinv hq y), <- (grinvinv hq z).
  change (hqmax (hqmax (- - x) (- - y)) (- - z) =
          hqmax (- - x) (hqmax (- - y) (- - z))).
  rewrite !hqmaxopp_opphqmin.
  apply maponpaths, isassoc_hqmin.
Qed.
Lemma iscomm_hqmax : iscomm hqmax.
Proof.
  intros x y.
  rewrite <- (grinvinv hq x), <- (grinvinv hq y).
  change (hqmax (- - x) (- - y) = hqmax (- - y) (- - x)).
  rewrite !hqmaxopp_opphqmin.
  apply maponpaths, iscomm_hqmin.
Qed.
Lemma isabsorb_hqmin_hqmax :
  Π x y : hq, hqmin x (hqmax x y) = x.
Proof.
  intros x y.
  unfold hqmin, hqmax.
  induction (hqgthorleh x y) as [Hxy | Hxy].
  - change (sumofmaps (λ _ : x > y, x) (λ _ : x <= y, y) (ii1 Hxy)) with x.
    induction (hqgthorleh x x) as [Hxx | Hxx].
    reflexivity.
    reflexivity.
  - change (sumofmaps (λ _ : x > y, x) (λ _ : x <= y, y) (ii2 Hxy)) with y.
    induction (hqgthorleh x y) as [Hxy' | Hxy'].
    apply fromempty.
    revert Hxy'.
    apply Hxy.
    reflexivity.
Qed.
Lemma isabsorb_hqmax_hqmin :
  Π x y : hq, hqmax x (hqmin x y) = x.
Proof.
  intros x y.
  unfold hqmin, hqmax.
  induction (hqgthorleh x y) as [Hxy | Hxy].
  - change (sumofmaps (λ _ : x > y, y) (λ _ : x <= y, x) (ii1 Hxy)) with y.
    induction (hqgthorleh x y) as [Hxy' | Hxy'].
    reflexivity.
    apply fromempty.
    revert Hxy.
    apply Hxy'.
  - change (sumofmaps (λ _ : x > y, y) (λ _ : x <= y, x) (ii2 Hxy)) with x.
    induction (hqgthorleh x x) as [Hxx | Hxx].
    reflexivity.
    reflexivity.
Qed.

Lemma islatticeop_hq :
  islatticeop hqmin hqmax.
Proof.
  repeat split.
  - exact isassoc_hqmin.
  - exact iscomm_hqmin.
  - exact isassoc_hqmax.
  - exact iscomm_hqmax.
  - exact isabsorb_hqmin_hqmax.
  - exact isabsorb_hqmax_hqmin.
Qed.

Lemma nothqgth_hqmin :
  Π x y : hq, ¬ (x > y) <-> hqmin x y = x.
Proof.
  intros x y.
  apply hqmin_case_strong ; intros H ; split ; intros H0.
  - reflexivity.
  - exact H.
  - apply isantisymmhqleh.
    exact H.
    exact H0.
  - rewrite H0.
    apply (isirreflhqgth x).
Qed.

Lemma hqmin_gt :
  Π x y z : hq, x > z → y > z → hqmin x y > z.
Proof.
  intros x y z Hx Hy.
  apply hqmin_case.
  exact Hx.
  exact Hy.
Qed.
Lemma hqmax_lt :
  Π x y z : hq, z > x → z > y → z > hqmax x y.
Proof.
  intros x y z Hx Hy.
  apply hqmax_case.
  exact Hx.
  exact Hy.
Qed.

Definition islattice_hq : islatticewithgt hq.
Proof.
  mkpair.
  exact (hqmin ,, hqmax ,, islatticeop_hq).
  mkpair.
  - mkpair.
    exact hqgth.
    split ; [ | split].
    + exact istranshqgth.
    + exact iscotranshqgth.
    + exact isirreflhqgth.
  - split ; [ | split].
    + exact nothqgth_hqmin.
    + exact hqmin_gt.
    + exact hqmax_lt.
Defined.

Lemma Lmin_hqmin :
  Lmin islattice_hq = hqmin.
Proof.
  unfold Lmin, islattice_hq.
  simpl.
  reflexivity.
Qed.
Lemma Lmax_hqmax :
  Lmax islattice_hq = hqmax.
Proof.
  unfold Lmax, islattice_hq.
  simpl.
  reflexivity.
Qed.

Lemma Lle_hqleh :
  Π x y : hq, x <= y <-> Lle islattice_hq x y.
Proof.
  intros x y.
  split.
  - intros H.
    change (hqmin x y = x).
    unfold hqmin.
    induction (hqgthorleh x y) as [ Hxy | Hxy ].
    + apply fromempty.
      revert Hxy.
      exact H.
    + reflexivity.
  - intros H.
    rewrite <- H.
    change (hqmin x y <= y).
    unfold hqmin.
    induction (hqgthorleh x y) as [Hxy | Hxy].
    + exact (isreflhqleh _).
    + exact Hxy.
Qed.

Lemma hqmax_ge_l :
  Π (x y : hq), x <= hqmax x y.
Proof.
  intros x y.
  apply_pr2 Lle_hqleh.
  rewrite <- Lmax_hqmax.
  apply (Lmax_ge_l islattice_hq).
Qed.
Lemma hqmax_ge_r :
  Π (x y : hq), y <= hqmax x y.
Proof.
  intros x y.
  apply_pr2 Lle_hqleh.
  rewrite <- Lmax_hqmax.
  apply (Lmax_ge_r islattice_hq).
Qed.
Lemma hqmax_eq_l :
  Π (x y : hq), y <= x → hqmax x y = x.
Proof.
  intros x y H.
  rewrite <- Lmax_hqmax.
  apply (Lmax_le_eq_l islattice_hq).
  apply Lle_hqleh.
  exact H.
Qed.
Lemma hqmax_eq_r :
  Π (x y : hq), x <= y → hqmax x y = y.
Proof.
  intros x y H.
  rewrite <- Lmax_hqmax.
  apply (Lmax_le_eq_r islattice_hq).
  apply Lle_hqleh.
  exact H.
Qed.
Lemma hqmax_gth_l :
  Π x y : hq, y > x <-> hqmax x y > x.
Proof.
  intros x y.
  apply hqmax_case_strong.
  - intros H ; split ; intros H0.
    + apply fromempty.
      refine (hqlehtoneghqgth _ _ _ _).
      exact H.
      exact H0.
    + apply fromempty.
      refine (isirreflhqgth _ _).
      exact H0.
  - split ; intros H0 ; exact H0.
Qed.

Lemma isrdistr_hqmax_hqplus :
  isrdistr hqmax hqplus.
Proof.
  intros x y k.
  apply hqmax_case_strong ; intros H ;
  apply hqmax_case_strong ; intros H0.
  - reflexivity.
  - apply isantisymmhqleh.
    exact H0.
    apply hqlehandplusr, H.
  - apply isantisymmhqleh.
    exact H0.
    apply hqlehandplusr, H.
  - reflexivity.
Qed.

Definition hqtruncminus : binop hq :=
  λ x y : hq, hqmax 0 (x - y).
Lemma istruncminus_hq :
  istruncminus (X := rngaddabgr hq) islattice_hq hqtruncminus.
Proof.
  unfold hqtruncminus.
  rewrite <- Lmax_hqmax.
  apply (abgr_truncminus (X := rngaddabgr hq) islattice_hq).
  exact isrdistr_hqmax_hqplus.
Qed.

Lemma hqtruncminus_pos :
  Π x y : hq, x > y <-> hqtruncminus x y > 0.
Proof.
  unfold hqtruncminus.
  intros x y ; split.
  - intros H.
    apply hqmax_gth_l.
    unfold hqminus.
    apply hqgthandplusrinv with y.
    rewrite hqplusassoc, hqlminus, hqplusl0, hqplusr0.
    exact H.
  - intros H.
    apply_pr2_in hqmax_gth_l H.
    apply hqgthandplusrinv with (- y).
    change (x - y > y - y).
    rewrite hqrminus.
    exact H.
Qed.

Definition extruncminus_hq : extruncminuswithgt (X := rngaddabgr hq) islattice_hq.
Proof.
  mkpair.
  exact (hqtruncminus,, istruncminus_hq).
  exact (λ x y : hq, pr2 (hqtruncminus_pos x y)).
Defined.

Close Scope hq_scope.
