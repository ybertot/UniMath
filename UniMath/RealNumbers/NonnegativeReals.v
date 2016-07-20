(** * Definition of Dedekind cuts for non-negative real numbers *)
(** Catherine Lelay. Sep. 2015 *)

Require Import UniMath.RealNumbers.Sets.
Require Export UniMath.Foundations.Algebra.ConstructiveStructures.
Require Import UniMath.RealNumbers.Prelim.
Require Import UniMath.RealNumbers.NonnegativeRationals.

Delimit Scope Dcuts_scope with Dcuts.
Local Open Scope NRat_scope.
Local Open Scope Dcuts_scope.
Local Open Scope tap_scope.

(** ** Definition of Dedekind cuts *)

Definition Dcuts_def_bot (X : hsubtypes NonnegativeRationals) : UU :=
  Π x : NonnegativeRationals,
        X x -> Π y : NonnegativeRationals, y <= x -> X y.
Definition Dcuts_def_open (X : hsubtypes NonnegativeRationals) : UU :=
  Π x : NonnegativeRationals,
        X x -> ∃ y : NonnegativeRationals, (X y) × (x < y).
Definition Dcuts_def_finite (X : hsubtypes NonnegativeRationals) : hProp :=
  ∃ ub : NonnegativeRationals, ¬ (X ub).
Definition Dcuts_def_error (X : hsubtypes NonnegativeRationals) : UU :=
  Π r : NonnegativeRationals, 0 < r -> (¬ (X r)) ∨ Σ q : NonnegativeRationals, (X q) × (¬ (X (q + r))).

Lemma Dcuts_def_error_finite (X : hsubtypes NonnegativeRationals) :
  Dcuts_def_error X → Dcuts_def_finite X.
Proof.
  intros X Hx.
  specialize (Hx _ ispositive_oneNonnegativeRationals).
  revert Hx ; apply hinhuniv ; apply sumofmaps ; [intros Hx |  intros x].
  - apply hinhpr.
    exists 1 ; exact Hx.
  - apply hinhpr ; exists (pr1 x + 1) ; exact (pr2 (pr2 x)).
Qed.

Lemma Dcuts_def_error_not_empty (X : hsubtypes NonnegativeRationals) :
  X 0 -> Dcuts_def_error X ->
  Π c : NonnegativeRationals,
    (0 < c)%NRat -> ∃ x : NonnegativeRationals, X x × ¬ X (x + c).
Proof.
  intros X X0 Hx c Hc.
  generalize (Hx c Hc).
  apply hinhuniv ; apply sumofmaps ; [intros nXc | intros Hx' ].
  - apply hinhpr ; exists 0%NRat ; split.
    exact X0.
    rewrite islunit_zeroNonnegativeRationals.
    exact nXc.
  - apply hinhpr ; exact Hx'.
Qed.

Lemma isaprop_Dcuts_def_bot (X : hsubtypes NonnegativeRationals) : isaprop (Dcuts_def_bot X).
Proof.
  intros X.
  repeat (apply impred_isaprop ; intro).
  now apply pr2.
Qed.
Lemma isaprop_Dcuts_def_open (X : hsubtypes NonnegativeRationals) : isaprop (Dcuts_def_open X).
Proof.
  intros X.
  repeat (apply impred_isaprop ; intro).
  now apply pr2.
Qed.
Lemma isaprop_Dcuts_def_error (X : hsubtypes NonnegativeRationals) : isaprop (Dcuts_def_error X).
Proof.
  intros X.
  repeat (apply impred_isaprop ; intro).
  now apply pr2.
Qed.

Lemma isaprop_Dcuts_hsubtypes (X : hsubtypes NonnegativeRationals) :
  isaprop (Dcuts_def_bot X × Dcuts_def_open X × Dcuts_def_error X).
Proof.
  intro X.
  apply isofhleveldirprod, isofhleveldirprod.
  - exact (isaprop_Dcuts_def_bot X).
  - exact (isaprop_Dcuts_def_open X).
  - exact (isaprop_Dcuts_def_error X).
Qed.

Definition Dcuts_hsubtypes : hsubtypes (hsubtypes NonnegativeRationals) :=
  fun X : hsubtypes NonnegativeRationals => hProppair _ (isaprop_Dcuts_hsubtypes X).
Lemma isaset_Dcuts : isaset (carrier Dcuts_hsubtypes).
Proof.
  apply isasetsubset with pr1.
  apply isasethsubtypes.
  apply isinclpr1.
  intro x.
  apply pr2.
Qed.
Definition Dcuts_set : hSet := hSetpair _ isaset_Dcuts.
Definition pr1Dcuts (x : Dcuts_set) : hsubtypes NonnegativeRationals := pr1 x.
Notation "x ∈ X" := (pr1Dcuts X x) (at level 70, no associativity) : DC_scope.

Open Scope DC_scope.

Lemma is_Dcuts_bot (X : Dcuts_set) : Dcuts_def_bot (pr1 X).
Proof.
  destruct X as [X (Hbot,(Hopen,Hfinite))] ; simpl.
  exact Hbot.
Qed.
Lemma is_Dcuts_open (X : Dcuts_set) : Dcuts_def_open (pr1 X).
Proof.
  destruct X as [X (Hbot,(Hopen,Hfinite))] ; simpl.
  exact Hopen.
Qed.
Lemma is_Dcuts_error (X : Dcuts_set) : Dcuts_def_error (pr1 X).
Proof.
  destruct X as [X (Hbot,(Hopen,Hfinite))] ; simpl.
  now apply Hfinite.
Qed.

Definition mk_Dcuts (X : NonnegativeRationals → hProp)
                    (Hbot : Dcuts_def_bot X)
                    (Hopen : Dcuts_def_open X)
                    (Herror : Dcuts_def_error X) : Dcuts_set.
Proof.
  intros X Hbot Hopen Herror.
  exists X ; repeat split.
  now apply Hbot.
  now apply Hopen.
  now apply Herror.
Defined.

Lemma Dcuts_finite :
  Π X : Dcuts_set, Π r : NonnegativeRationals,
    neg (r ∈ X) -> Π n : NonnegativeRationals, n ∈ X -> n < r.
Proof.
  intros X r Hr n Hn.
  apply notge_ltNonnegativeRationals ; intro Hn'.
  apply Hr.
  apply is_Dcuts_bot with n.
  exact Hn.
  exact Hn'.
Qed.

(** ** [Dcuts] is a effectively ordered set *)

(** Partial order on [Dcuts] *)

Definition Dcuts_le_rel : hrel Dcuts_set :=
  λ X Y : Dcuts_set,
          hProppair (Π x : NonnegativeRationals, x ∈ X -> x ∈ Y)
                    (impred_isaprop _ (λ _, isapropimpl _ _ (pr2 _))).

Lemma istrans_Dcuts_le_rel : istrans Dcuts_le_rel.
Proof.
  intros x y z Hxy Hyz r Xr.
  refine (Hyz _ _). now refine (Hxy _ _).
Qed.
Lemma isrefl_Dcuts_le_rel : isrefl Dcuts_le_rel.
Proof.
  now intros X x Xx.
Qed.

Lemma ispreorder_Dcuts_le_rel : ispreorder Dcuts_le_rel.
Proof.
  split.
  exact istrans_Dcuts_le_rel.
  exact isrefl_Dcuts_le_rel.
Qed.

(** Strict partial order on [Dcuts] *)

Definition Dcuts_lt_rel : hrel Dcuts_set :=
  fun (X Y : Dcuts_set) =>
    ∃ x : NonnegativeRationals, dirprod (neg (x ∈ X)) (x ∈ Y).

Lemma istrans_Dcuts_lt_rel : istrans Dcuts_lt_rel.
Proof.
  intros x y z.
  apply hinhfun2.
  intros r n.
  exists (pr1 r) ; split.
  exact (pr1 (pr2 r)).
  apply is_Dcuts_bot with (pr1 n).
  exact (pr2 (pr2 n)).
  apply lt_leNonnegativeRationals.
  apply Dcuts_finite with y.
  exact (pr1 (pr2 n)).
  exact (pr2 (pr2 r)).
Qed.
Lemma isirrefl_Dcuts_lt_rel : isirrefl Dcuts_lt_rel.
Proof.
  intros x.
  unfold neg ;
  apply (hinhuniv (P := hProppair _ isapropempty)).
  intros r.
  apply (pr1 (pr2 r)).
  exact (pr2 (pr2 r)).
Qed.
Lemma iscotrans_Dcuts_lt_rel :
  iscotrans Dcuts_lt_rel.
Proof.
  intros x y z.
  apply hinhuniv ; intros r.
  generalize (is_Dcuts_open _ _ (pr2 (pr2 r))) ; apply hinhuniv ; intros r'.
  assert (Hr0 : 0%NRat < pr1 r' - pr1 r).
  { apply ispositive_minusNonnegativeRationals.
    exact (pr2 (pr2 r')). }
  generalize (is_Dcuts_error y _ Hr0) ; apply hinhuniv ; apply sumofmaps ; [intros Yq | intros q].
  - apply Utilities.squash_element ;
    right ; apply Utilities.squash_element.
    exists (pr1 r') ; split.
    + intro H0 ; apply Yq.
      apply is_Dcuts_bot with (pr1 r').
      exact H0.
      now apply minusNonnegativeRationals_le.
    + exact (pr1 (pr2 r')).
  - generalize (isdecrel_leNonnegativeRationals (pr1 q + (pr1 r' - pr1 r)) (pr1 r')) ; apply sumofmaps ; intros Hdec.
    + apply hinhpr ; right ; apply hinhpr.
      exists (pr1 r') ; split.
      intro Yr' ; apply (pr2 (pr2 q)).
      apply is_Dcuts_bot with (pr1 r').
      exact Yr'.
      exact Hdec.
      exact (pr1 (pr2 r')).
    + apply hinhpr ; left ; apply hinhpr.
      exists (pr1 q) ; split.
      * intro Xq ; apply (pr1 (pr2 r)).
        apply is_Dcuts_bot with (pr1 q).
        exact Xq.
        apply notge_ltNonnegativeRationals in Hdec.
        apply (plusNonnegativeRationals_ltcompat_r (pr1 r)) in Hdec ;
          rewrite isassoc_plusNonnegativeRationals, minusNonnegativeRationals_plus_r, iscomm_plusNonnegativeRationals in Hdec.
        apply_pr2_in plusNonnegativeRationals_ltcompat_r Hdec.
        now apply lt_leNonnegativeRationals, Hdec.
        now apply lt_leNonnegativeRationals, (pr2 (pr2 r')).
      * exact (pr1 (pr2 q)).
Qed.

Lemma isstpo_Dcuts_lt_rel : isStrongOrder Dcuts_lt_rel.
Proof.
  repeat split.
  exact istrans_Dcuts_lt_rel.
  exact iscotrans_Dcuts_lt_rel.
  exact isirrefl_Dcuts_lt_rel.
Qed.

(** Effectively Ordered Set *)

Lemma Dcuts_lt_le_rel :
  Π x y : Dcuts_set, Dcuts_lt_rel x y -> Dcuts_le_rel x y.
Proof.
  intros x y ; apply hinhuniv ; intros r.
  intros n Xn.
  apply is_Dcuts_bot with (pr1 r).
  exact (pr2 (pr2 r)).
  apply lt_leNonnegativeRationals.
  apply Dcuts_finite with x.
  exact (pr1 (pr2 r)).
  exact Xn.
Qed.

Lemma Dcuts_le_ngt_rel :
  Π x y : Dcuts_set, ¬ Dcuts_lt_rel x y <-> Dcuts_le_rel y x.
Proof.
  intros X Y.
  split.
  - intros Hnlt y Yy.
    generalize (is_Dcuts_open _ _ Yy) ; apply hinhuniv ; intros y'.
    generalize (pr1 (ispositive_minusNonnegativeRationals _ _) (pr2 (pr2 y'))) ; intros Hy.
    generalize (is_Dcuts_error X _ Hy).
    apply hinhuniv.
    apply sumofmaps ; [intros nXc | ].
    + apply fromempty, Hnlt.
      apply hinhpr.
      exists (pr1 y') ; split.
      * intro Xy' ; apply nXc.
        apply is_Dcuts_bot with (1 := Xy').
        now apply minusNonnegativeRationals_le.
      * exact (pr1 (pr2 y')).
    + intros x.
      apply is_Dcuts_bot with (1 := pr1 (pr2 x)).
      apply notlt_geNonnegativeRationals ; intro H ; apply Hnlt.
      apply hinhpr.
      exists (pr1 x + (pr1 y' - y)) ; split.
      * exact (pr2 (pr2 x)).
      * apply is_Dcuts_bot with (1 := pr1 (pr2 y')).
        pattern (pr1 y') at 3 ; rewrite <- (minusNonnegativeRationals_plus_r y (pr1 y')).
        rewrite iscomm_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_l.
        now apply lt_leNonnegativeRationals, H.
        apply lt_leNonnegativeRationals ; apply_pr2 ispositive_minusNonnegativeRationals.
        exact Hy.
  - intros Hxy ; unfold neg.
    apply (hinhuniv (P := hProppair _ isapropempty)) ;
    intros r.
    refine (pr1 (pr2 r) _).
    refine (Hxy _ _).
    exact (pr2 (pr2 r)).
Qed.

Lemma istrans_Dcuts_lt_le_rel :
  Π x y z : Dcuts_set, Dcuts_lt_rel x y -> Dcuts_le_rel y z -> Dcuts_lt_rel x z.
Proof.
  intros x y z Hlt Hle.
  revert Hlt ; apply hinhfun ; intros r.
  exists (pr1 r) ; split.
  - exact (pr1 (pr2 r)).
  - refine (Hle _ _).
    exact (pr2 (pr2 r)).
Qed.
Lemma istrans_Dcuts_le_lt_rel :
  Π x y z : Dcuts_set, Dcuts_le_rel x y -> Dcuts_lt_rel y z -> Dcuts_lt_rel x z.
Proof.
  intros x y z Hle.
  apply hinhfun ; intros r.
  exists (pr1 r) ; split.
  - intros Xr ; apply (pr1 (pr2 r)).
    now refine (Hle _ _).
  - exact (pr2 (pr2 r)).
Qed.

Lemma iseo_Dcuts_le_lt_rel :
  isEffectiveOrder Dcuts_le_rel Dcuts_lt_rel.
Proof.
  split.
  - split.
    + exact ispreorder_Dcuts_le_rel.
    + exact isstpo_Dcuts_lt_rel.
  - repeat split.
    + now apply Dcuts_le_ngt_rel.
    + apply (pr2 (Dcuts_le_ngt_rel _ _)).
    + exact istrans_Dcuts_lt_le_rel.
    + exact istrans_Dcuts_le_lt_rel.
Qed.

Definition iseo_Dcuts : EffectiveOrder Dcuts_set :=
  pairEffectiveOrder Dcuts_le_rel Dcuts_lt_rel iseo_Dcuts_le_lt_rel.

Definition eo_Dcuts : EffectivelyOrderedSet :=
  pairEffectivelyOrderedSet iseo_Dcuts.

Definition Dcuts_le : po Dcuts_set := @EOle eo_Dcuts.
Definition Dcuts_ge : po Dcuts_set := @EOge eo_Dcuts.
Definition Dcuts_lt : StrongOrder Dcuts_set := @EOlt eo_Dcuts.
Definition Dcuts_gt : StrongOrder Dcuts_set := @EOgt eo_Dcuts.

Notation "x <= y" := (@EOle_rel eo_Dcuts x y) : Dcuts_scope.
Notation "x >= y" := (@EOge_rel eo_Dcuts x y) : Dcuts_scope.
Notation "x < y" := (@EOlt_rel eo_Dcuts x y) : Dcuts_scope.
Notation "x > y" := (@EOgt_rel eo_Dcuts x y) : Dcuts_scope.

(** ** Equivalence on [Dcuts] *)

Definition Dcuts_eq_rel :=
  λ X Y : Dcuts_set, Π r : NonnegativeRationals, (r ∈ X -> r ∈ Y) × (r ∈ Y -> r ∈ X).
Lemma isaprop_Dcuts_eq_rel : Π X Y : Dcuts_set, isaprop (Dcuts_eq_rel X Y).
Proof.
  intros X Y.
  apply impred_isaprop ; intro r.
  apply isapropdirprod.
  - now apply isapropimpl, pr2.
  - now apply isapropimpl, pr2.
Qed.
Definition Dcuts_eq : hrel Dcuts_set :=
  λ X Y : Dcuts_set, hProppair (Π r, dirprod (r ∈ X -> r ∈ Y) (r ∈ Y -> r ∈ X)) (isaprop_Dcuts_eq_rel X Y).

Lemma istrans_Dcuts_eq : istrans Dcuts_eq.
Proof.
  intros x y z Hxy Hyz r.
  split.
  - intros Xr.
    now apply (pr1 (Hyz r)), (pr1 (Hxy r)), Xr.
  - intros Zr.
    now apply (pr2 (Hxy r)), (pr2 (Hyz r)), Zr.
Qed.
Lemma isrefl_Dcuts_eq : isrefl Dcuts_eq.
Proof.
  intros x r.
  now split.
Qed.
Lemma ispreorder_Dcuts_eq : ispreorder Dcuts_eq.
Proof.
  split.
  exact istrans_Dcuts_eq.
  exact isrefl_Dcuts_eq.
Qed.

Lemma issymm_Dcuts_eq : issymm Dcuts_eq.
Proof.
  intros x y Hxy r.
  split.
  exact (pr2 (Hxy r)).
  exact (pr1 (Hxy r)).
Qed.

Lemma iseqrel_Dcuts_eq : iseqrel Dcuts_eq.
Proof.
  split.
  exact ispreorder_Dcuts_eq.
  exact issymm_Dcuts_eq.
Qed.

Lemma Dcuts_eq_is_eq :
  Π x y : Dcuts_set,
    Dcuts_eq x y -> x = y.
Proof.
  intros x y Heq.
  apply subtypeEquality_prop.
  apply funextsec.
  intro r.
  apply hPropUnivalence.
  exact (pr1 (Heq r)).
  exact (pr2 (Heq r)).
Qed.

(** ** Apartness on [Dcuts] *)

Lemma isaprop_Dcuts_ap_rel (X Y : Dcuts_set) :
  isaprop ((X < Y) ⨿ (Y < X)).
Proof.
  intros X Y.
  apply (isapropcoprod (X < Y) (Y < X)
                       (propproperty (X < Y))
                       (propproperty (Y < X))
                       (λ Hlt : X < Y, pr2 (Dcuts_le_ngt_rel Y X) (Dcuts_lt_le_rel X Y Hlt))).
Qed.
Definition Dcuts_ap_rel (X Y : Dcuts_set) : hProp :=
  hProppair ((X < Y) ⨿ (Y < X)) (isaprop_Dcuts_ap_rel X Y).

Lemma isirrefl_Dcuts_ap_rel : isirrefl Dcuts_ap_rel.
Proof.
  intros x.
  unfold neg.
  apply sumofmaps.
  now apply isirrefl_Dcuts_lt_rel.
  now apply isirrefl_Dcuts_lt_rel.
Qed.
Lemma issymm_Dcuts_ap_rel : issymm Dcuts_ap_rel.
Proof.
  intros x y.
  apply coprodcomm.
Qed.
Lemma iscotrans_Dcuts_ap_rel : iscotrans Dcuts_ap_rel.
Proof.
  intros x y z.
  apply sumofmaps ; intros Hap.
  - generalize (iscotrans_Dcuts_lt_rel _ y _ Hap) ; apply hinhfun.
    apply sumofmaps ; intros Hy.
    + now left ; left.
    + now right ; left.
  - generalize (iscotrans_Dcuts_lt_rel _ y _ Hap) ; apply hinhfun.
    apply sumofmaps ; intros Hy.
    + now right ; right.
    + now left ; right.
Qed.

Lemma istight_Dcuts_ap_rel : istight Dcuts_ap_rel.
Proof.
  intros X Y Hap.
  apply Dcuts_eq_is_eq.
  intros r ; split ; revert r.
  - change (X <= Y).
    apply Dcuts_le_ngt_rel.
    intro Hlt ; apply Hap.
    now right.
  - change (Y <= X).
    apply Dcuts_le_ngt_rel.
    intro Hlt ; apply Hap.
    now left.
Qed.

Definition Dcuts : tightapSet :=
  Dcuts_set ,, Dcuts_ap_rel ,,
    (isirrefl_Dcuts_ap_rel ,, issymm_Dcuts_ap_rel ,, iscotrans_Dcuts_ap_rel) ,,
    istight_Dcuts_ap_rel.

Lemma not_Dcuts_ap_eq :
  Π x y : Dcuts, ¬ (x ≠ y) -> (x = y).
Proof.
  intros x y.
  now apply istight_Dcuts_ap_rel.
Qed.

(** *** Various theorems about order *)

Lemma Dcuts_ge_le :
  Π x y : Dcuts, x >= y -> y <= x.
Proof.
  easy.
Qed.
Lemma Dcuts_le_ge :
  Π x y : Dcuts, x <= y -> y >= x.
Proof.
  easy.
Qed.
Lemma Dcuts_eq_le :
  Π x y : Dcuts, Dcuts_eq x y -> x <= y.
Proof.
  intros x y Heq.
  intro r ;
    now apply (pr1 (Heq _)).
Qed.
Lemma Dcuts_eq_ge :
  Π x y : Dcuts, Dcuts_eq x y -> x >= y.
Proof.
  intros x y Heq.
  apply Dcuts_eq_le.
  now apply issymm_Dcuts_eq.
Qed.
Lemma Dcuts_le_ge_eq :
  Π x y : Dcuts, x <= y -> x >= y -> x = y.
Proof.
  intros x y le_xy ge_xy.
  apply Dcuts_eq_is_eq.
  split.
  now refine (le_xy _).
  now refine (ge_xy _).
Qed.

Lemma Dcuts_gt_lt :
  Π x y : Dcuts, (x > y) <-> (y < x).
Proof.
  now split.
Qed.
Lemma Dcuts_gt_ge :
  Π x y : Dcuts, x > y -> x >= y.
Proof.
  intros x y.
  now apply Dcuts_lt_le_rel.
Qed.

Lemma Dcuts_gt_nle :
  Π x y : Dcuts, x > y -> neg (x <= y).
Proof.
  intros x y Hlt Hle.
  now apply (pr2 (Dcuts_le_ngt_rel _ _)) in Hle.
Qed.
Lemma Dcuts_nlt_ge :
  Π x y : Dcuts, neg (x < y) <-> (x >= y).
Proof.
  intros X Y.
  now apply Dcuts_le_ngt_rel.
Qed.
Lemma Dcuts_lt_nge :
  Π x y : Dcuts, x < y -> neg (x >= y).
Proof.
  intros x y.
  now apply Dcuts_gt_nle.
Qed.

(** * Algebraic structures on Dcuts *)

(** ** From non negative rational numbers to Dedekind cuts *)

Lemma NonnegativeRationals_to_Dcuts_bot (q : NonnegativeRationals) :
  Dcuts_def_bot (λ r : NonnegativeRationals, (r < q)%NRat).
Proof.
  intros q r Hr n Hnr.
  now apply istrans_le_lt_ltNonnegativeRationals with r.
Qed.
Lemma NonnegativeRationals_to_Dcuts_open (q : NonnegativeRationals) :
  Dcuts_def_open (λ r : NonnegativeRationals, (r < q)%NRat).
Proof.
  intros q r Hr.
  apply hinhpr.
  generalize (between_ltNonnegativeRationals r q Hr) ; intros n.
  exists (pr1 n).
  split.
  exact (pr2 (pr2 n)).
  exact (pr1 (pr2 n)).
Qed.
Lemma NonnegativeRationals_to_Dcuts_error (q : NonnegativeRationals) :
  Dcuts_def_error (λ r : NonnegativeRationals, (r < q)%NRat).
Proof.
  intros q.
  intros r Hr0.
  apply hinhpr.
  generalize (isdecrel_ltNonnegativeRationals r q) ; apply sumofmaps ; intros Hqr.
  - right.
    assert (Hn0 : (0 < q - r)%NRat) by (now apply ispositive_minusNonnegativeRationals).
    exists (q - r).
    split.
    + apply_pr2 (plusNonnegativeRationals_ltcompat_r r).
      rewrite minusNonnegativeRationals_plus_r.
      pattern q at 1 ;
        rewrite <- isrunit_zeroNonnegativeRationals.
      apply plusNonnegativeRationals_ltcompat_l.
      exact Hr0.
      now apply lt_leNonnegativeRationals, Hqr.
    + rewrite minusNonnegativeRationals_plus_r.
      now apply isirrefl_ltNonnegativeRationals.
      now apply lt_leNonnegativeRationals, Hqr.
  - now left.
Qed.

Definition NonnegativeRationals_to_Dcuts (q : NonnegativeRationals) : Dcuts :=
  mk_Dcuts (fun r => (r < q)%NRat)
           (NonnegativeRationals_to_Dcuts_bot q)
           (NonnegativeRationals_to_Dcuts_open q)
           (NonnegativeRationals_to_Dcuts_error q).


Lemma isapfun_NonnegativeRationals_to_Dcuts_aux :
  Π q q' : NonnegativeRationals,
    NonnegativeRationals_to_Dcuts q < NonnegativeRationals_to_Dcuts q'
    <-> (q < q')%NRat.
Proof.
  intros q q'.
  split.
  - apply hinhuniv.
    intros r.
    apply istrans_le_lt_ltNonnegativeRationals with (pr1 r).
    + apply notlt_geNonnegativeRationals.
      exact (pr1 (pr2 r)).
    + exact (pr2 (pr2 r)).
  - intros H.
    apply hinhpr.
    exists q ; split.
    now apply (isirrefl_ltNonnegativeRationals q).
    exact H.
Qed.
Lemma isapfun_NonnegativeRationals_to_Dcuts :
  Π q q' : NonnegativeRationals,
    NonnegativeRationals_to_Dcuts q ≠ NonnegativeRationals_to_Dcuts q'
    → q != q'.
Proof.
  intros q q'.
  apply sumofmaps ; intros Hap.
  now apply ltNonnegativeRationals_noteq, isapfun_NonnegativeRationals_to_Dcuts_aux.
  now apply gtNonnegativeRationals_noteq, isapfun_NonnegativeRationals_to_Dcuts_aux.
Qed.
Lemma isapfun_NonnegativeRationals_to_Dcuts' :
  Π q q' : NonnegativeRationals,
    q != q'
    → NonnegativeRationals_to_Dcuts q ≠ NonnegativeRationals_to_Dcuts q'.
Proof.
  intros q q' H.
  apply noteq_ltorgtNonnegativeRationals in H.
  destruct H.
  now left ; apply (pr2 (isapfun_NonnegativeRationals_to_Dcuts_aux _ _)).
  now right ; apply (pr2 (isapfun_NonnegativeRationals_to_Dcuts_aux _ _)).
Qed.

Definition Dcuts_zero : Dcuts := NonnegativeRationals_to_Dcuts 0%NRat.
Definition Dcuts_one : Dcuts := NonnegativeRationals_to_Dcuts 1%NRat.
Definition Dcuts_two : Dcuts := NonnegativeRationals_to_Dcuts 2.

Notation "0" := Dcuts_zero : Dcuts_scope.
Notation "1" := Dcuts_one : Dcuts_scope.
Notation "2" := Dcuts_two : Dcuts_scope.

(** Various usefull theorems *)

Lemma Dcuts_zero_empty :
  Π r : NonnegativeRationals, neg (r ∈ 0).
Proof.
  intros r ; simpl.
  change (neg (r < 0)%NRat).
  now apply isnonnegative_NonnegativeRationals'.
Qed.
Lemma Dcuts_notempty_notzero :
  Π (x : Dcuts) (r : NonnegativeRationals), r ∈ x -> x ≠ 0.
Proof.
  intros x r Hx.
  right.
  apply hinhpr.
  exists r.
  split.
  now apply Dcuts_zero_empty.
  exact Hx.
Qed.

Lemma Dcuts_ge_0 :
  Π x : Dcuts, Dcuts_zero <= x.
Proof.
  intros x r Hr.
  apply fromempty.
  revert Hr.
  now apply Dcuts_zero_empty.
Qed.
Lemma Dcuts_notlt_0 :
  Π x : Dcuts, ¬ (x < Dcuts_zero).
Proof.
  intros x.
  unfold neg.
  apply hinhuniv'.
  exact isapropempty.
  intros r.
  exact (Dcuts_zero_empty _ (pr2 (pr2 r))).
Qed.

Lemma Dcuts_apzero_notempty :
  Π (x : Dcuts), (0%NRat ∈ x) <-> x ≠ 0.
Proof.
  intros x ; split.
  - now apply Dcuts_notempty_notzero.
  - apply sumofmaps.
    + apply hinhuniv ; intros r.
      apply fromempty.
      now apply (Dcuts_zero_empty _ (pr2 (pr2 r))).
    + apply hinhuniv ; intros r.
      apply is_Dcuts_bot with (1 := pr2 (pr2 r)).
      now apply isnonnegative_NonnegativeRationals.
Qed.

Lemma NonnegativeRationals_to_Dcuts_notin_le :
  Π (x : Dcuts) (r : NonnegativeRationals),
    ¬ (r ∈ x) -> x <= NonnegativeRationals_to_Dcuts r.
Proof.
  intros x r Hr q Hq.
  simpl.
  now apply (Dcuts_finite x).
Qed.

(** ** Addition in Dcuts *)

Section Dcuts_plus.

  Context (X : hsubtypes NonnegativeRationals).
  Context (X_bot : Dcuts_def_bot X).
  Context (X_open : Dcuts_def_open X).
  Context (X_error : Dcuts_def_error X).
  Context (Y : hsubtypes NonnegativeRationals).
  Context (Y_bot : Dcuts_def_bot Y).
  Context (Y_open : Dcuts_def_open Y).
  Context (Y_error : Dcuts_def_error Y).

Definition Dcuts_plus_val : hsubtypes NonnegativeRationals :=
  λ r : NonnegativeRationals,
        ((X r) ⨿ (Y r)) ∨
        (Σ xy : NonnegativeRationals × NonnegativeRationals, (r = (pr1 xy + pr2 xy)%NRat) × ((X (pr1 xy)) × (Y (pr2 xy)))).

Lemma Dcuts_plus_bot : Dcuts_def_bot Dcuts_plus_val.
Proof.
  intros r Hr n Hn.
  revert Hr ; apply hinhfun ;
  apply sumofmaps ; [apply sumofmaps ; intros Hr | intros xy].
  - left ; left.
    now apply X_bot with r.
  - left ; right.
    now apply Y_bot with r.
  - right.
    generalize (isdeceq_NonnegativeRationals r 0%NRat) ; apply sumofmaps ; intros Hr0.
    + rewrite Hr0 in Hn.
      apply NonnegativeRationals_eq0_le0 in Hn.
      exists (0%NRat,,0%NRat).
      rewrite Hn ; simpl.
      repeat split.
      * now rewrite isrunit_zeroNonnegativeRationals.
      * apply X_bot with (1 := pr1 (pr2 (pr2 xy))).
        apply isnonnegative_NonnegativeRationals.
      * apply Y_bot with (1 := pr2 (pr2 (pr2 xy))).
        apply isnonnegative_NonnegativeRationals.
    + set (nx := (pr1 (pr1 xy) * (n / r))%NRat).
      set (ny := (pr2 (pr1 xy) * (n / r))%NRat).
      exists (nx,,ny).
      repeat split.
      * unfold nx,ny ; simpl.
        rewrite <- isrdistr_mult_plusNonnegativeRationals, <- (pr1 (pr2 xy)).
        rewrite multdivNonnegativeRationals.
        reflexivity.
        now apply NonnegativeRationals_neq0_gt0.
      * apply X_bot with (1 := pr1 (pr2 (pr2 xy))).
        apply multNonnegativeRationals_le1_r.
        now apply divNonnegativeRationals_le1.
      * apply Y_bot with (1 := pr2 (pr2 (pr2 xy))).
        apply multNonnegativeRationals_le1_r.
        now apply divNonnegativeRationals_le1.
Qed.

Lemma Dcuts_plus_open : Dcuts_def_open Dcuts_plus_val.
Proof.
  intros r.
  apply hinhuniv, sumofmaps.
  - apply sumofmaps ; intro Hr.
    + generalize (X_open r Hr).
      apply hinhfun ; intros n.
      exists (pr1 n).
      split.
      * apply hinhpr ; left ; left.
        exact (pr1 (pr2 n)).
      * exact (pr2 (pr2 n)).
    + generalize (Y_open r Hr).
      apply hinhfun ; intros n.
      exists (pr1 n).
      split.
      * apply hinhpr ; left ; right.
        exact (pr1 (pr2 n)).
      * exact (pr2 (pr2 n)).
  - intros xy.
    generalize (X_open _ (pr1 (pr2 (pr2 xy)))) (Y_open _ (pr2 (pr2 (pr2 xy)))).
    apply hinhfun2.
    intros nx ny.
    exists (pr1 nx + pr1 ny).
    split.
    + apply hinhpr ; right ; exists (pr1 nx ,, pr1 ny).
      repeat split.
      * exact (pr1 (pr2 nx)).
      * exact (pr1 (pr2 ny)).
    + pattern r at 1 ;
      rewrite (pr1 (pr2 xy)).
      apply plusNonnegativeRationals_ltcompat.
      exact (pr2 (pr2 nx)).
      exact (pr2 (pr2 ny)).
Qed.
Lemma Dcuts_plus_error : Dcuts_def_error Dcuts_plus_val.
Proof.
  intros c Hc.
  apply ispositive_NQhalf in Hc.
  generalize (X_error _ Hc) (Y_error _ Hc).
  apply hinhfun2 ; apply (sumofmaps (Z := _ → _)) ; intros Hx ; apply sumofmaps ; intros Hy.
  - left.
    unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps.
    + apply sumofmaps ; intros Hz.
      * apply Hx.
        apply X_bot with (1 := Hz).
        pattern c at 2 ; rewrite (NQhalf_double c).
        apply plusNonnegativeRationals_le_r.
      * apply Hy.
        apply Y_bot with (1 := Hz).
        pattern c at 2 ; rewrite (NQhalf_double c).
        apply plusNonnegativeRationals_le_r.
    + intros xy.
      generalize (isdecrel_ltNonnegativeRationals (pr1 (pr1 xy)) (c / 2)%NRat) ; apply sumofmaps ; intros Hx'.
      generalize (isdecrel_ltNonnegativeRationals (pr2 (pr1 xy)) (c / 2)%NRat) ; apply sumofmaps ; intros Hy'.
      * apply (isirrefl_StrongOrder ltNonnegativeRationals c).
        pattern c at 2 ; rewrite (NQhalf_double c).
        pattern c at 1 ; rewrite (pr1 (pr2 xy)).
        apply plusNonnegativeRationals_ltcompat.
        exact Hx'.
        exact Hy'.
      * apply Hy.
        apply Y_bot with (1 := pr2 (pr2 (pr2 xy))).
        now apply notlt_geNonnegativeRationals ; apply Hy'.
      * apply Hx.
        apply X_bot with (1 := pr1 (pr2 (pr2 xy))).
        now apply notlt_geNonnegativeRationals ; apply Hx'.
  - right.
    rename Hy into q.
    exists (pr1 q) ; split.
    apply hinhpr.
    left ; right ; exact (pr1 (pr2 q)).
    unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps.
    apply sumofmaps ; [intros Xq | intros Yq'].
    + apply Hx ; apply X_bot with (1 := Xq).
      pattern c at 3 ; rewrite (NQhalf_double c).
      rewrite <- isassoc_plusNonnegativeRationals.
      apply plusNonnegativeRationals_le_l.
    + apply (pr2 (pr2 q)) ; apply Y_bot with (1 := Yq').
      pattern c at 4 ; rewrite (NQhalf_double c).
      rewrite <- isassoc_plusNonnegativeRationals.
      apply plusNonnegativeRationals_le_r.
    + intros xy.
      apply (isirrefl_StrongOrder ltNonnegativeRationals (pr1 q + c)).
      pattern c at 4 ; rewrite (NQhalf_double c).
      pattern (pr1 q + c) at 1 ; rewrite (pr1 (pr2 xy)).
      rewrite <- isassoc_plusNonnegativeRationals.
      rewrite iscomm_plusNonnegativeRationals.
      apply plusNonnegativeRationals_ltcompat.
      apply notge_ltNonnegativeRationals ; intro H.
      apply (pr2 (pr2 q)) ; apply Y_bot with (1 := pr2 (pr2 (pr2 xy))).
      exact H.
      apply notge_ltNonnegativeRationals ; intro H.
      apply Hx ; apply X_bot with (1 := pr1 (pr2 (pr2 xy))).
      exact H.
  - right.
    rename Hx into q.
    exists (pr1 q) ; split.
    apply hinhpr.
    left ; left ; exact (pr1 (pr2 q)).
    unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps.
    apply sumofmaps ; [intros Xq' | intros Yq].
    + apply (pr2 (pr2 q)) ; apply X_bot with (1 := Xq').
      pattern c at 4 ; rewrite (NQhalf_double c).
      rewrite <- isassoc_plusNonnegativeRationals.
      apply plusNonnegativeRationals_le_r.
    + apply Hy ; apply Y_bot with (1 := Yq).
      pattern c at 3 ; rewrite (NQhalf_double c).
      rewrite <- isassoc_plusNonnegativeRationals.
      apply plusNonnegativeRationals_le_l.
    + intros xy.
      apply (isirrefl_StrongOrder ltNonnegativeRationals (pr1 q + c)).
      pattern c at 4 ; rewrite (NQhalf_double c).
      pattern (pr1 q + c) at 1 ; rewrite (pr1 (pr2 xy)).
      rewrite <- isassoc_plusNonnegativeRationals.
      apply plusNonnegativeRationals_ltcompat.
      apply notge_ltNonnegativeRationals ; intro H.
      apply (pr2 (pr2 q)) ; apply X_bot with (1 := pr1 (pr2 (pr2 xy))).
      exact H.
      apply notge_ltNonnegativeRationals ; intro H.
      apply Hy ; apply Y_bot with (1 := pr2 (pr2 (pr2 xy))).
      exact H.
  - right.
    rename Hx into qx ; rename Hy into qy.
    exists (pr1 qx + pr1 qy).
    split.
    + apply hinhpr.
      right.
      exists (pr1 qx,,pr1 qy) ; repeat split.
      * exact (pr1 (pr2 qx)).
      * exact (pr1 (pr2 qy)).
    + unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps.
      apply sumofmaps ; [ intros Xq' | intros Yq'].
      * apply (pr2 (pr2 qx)), X_bot with (1 := Xq').
        pattern c at 5 ; rewrite (NQhalf_double c).
        rewrite <- isassoc_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_r.
        rewrite isassoc_plusNonnegativeRationals.
        apply plusNonnegativeRationals_le_r.
      * apply (pr2 (pr2 qy)), Y_bot with (1 := Yq').
        pattern c at 5 ; rewrite (NQhalf_double c).
        rewrite <- isassoc_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_r.
        eapply istrans_leNonnegativeRationals, plusNonnegativeRationals_le_r.
        apply plusNonnegativeRationals_le_l.
      * intros xy.
        apply (isirrefl_StrongOrder ltNonnegativeRationals (pr1 qx + pr1 qy + c)).
        pattern c at 6 ; rewrite (NQhalf_double c).
        pattern (pr1 qx + pr1 qy + c) at 1 ; rewrite (pr1 (pr2 xy)).
        rewrite <- isassoc_plusNonnegativeRationals.
        rewrite (isassoc_plusNonnegativeRationals (pr1 qx) (pr1 qy) (c / 2)%NRat).
        rewrite (iscomm_plusNonnegativeRationals (pr1 qy)).
        rewrite <- isassoc_plusNonnegativeRationals.
        rewrite (isassoc_plusNonnegativeRationals (pr1 qx + (c/2)%NRat)).
        apply plusNonnegativeRationals_ltcompat.
        apply notge_ltNonnegativeRationals ; intro H.
        apply (pr2 (pr2 qx)) ; apply X_bot with (1 := pr1 (pr2 (pr2 xy))) ; exact H.
        apply notge_ltNonnegativeRationals ; intro H.
        apply (pr2 (pr2 qy)) ; apply Y_bot with (1 := pr2 (pr2 (pr2 xy))) ; exact H.
Qed.

End Dcuts_plus.

Definition Dcuts_plus (X Y : Dcuts) : Dcuts :=
  mk_Dcuts (Dcuts_plus_val (pr1 X) (pr1 Y))
           (Dcuts_plus_bot (pr1 X) (is_Dcuts_bot X)
                           (pr1 Y) (is_Dcuts_bot Y))
           (Dcuts_plus_open (pr1 X) (is_Dcuts_open X)
                            (pr1 Y) (is_Dcuts_open Y))
           (Dcuts_plus_error (pr1 X) (is_Dcuts_bot X) (is_Dcuts_error X)
                             (pr1 Y) (is_Dcuts_bot Y) (is_Dcuts_error Y)).

(** ** Multiplication in Dcuts *)

Section Dcuts_NQmult.

  Context (x : NonnegativeRationals).
  Context (Hx : (0 < x)%NRat).
  Context (Y : hsubtypes NonnegativeRationals).
  Context (Y_bot : Dcuts_def_bot Y).
  Context (Y_open : Dcuts_def_open Y).
  Context (Y_finite : Dcuts_def_finite Y).
  Context (Y_error : Dcuts_def_error Y).

Definition Dcuts_NQmult_val : hsubtypes NonnegativeRationals :=
  fun r => ∃ ry : NonnegativeRationals, r = x * ry × Y ry.

Lemma Dcuts_NQmult_bot : Dcuts_def_bot Dcuts_NQmult_val.
Proof.
  intros r Hr n Hn.
  revert Hr ; apply hinhfun ;
  intros ry.
  generalize (isdeceq_NonnegativeRationals r 0%NRat) ;
    apply sumofmaps ; intros Hr0.
  - rewrite Hr0 in Hn.
    apply NonnegativeRationals_eq0_le0 in Hn.
    exists 0%NRat.
    rewrite Hn ; simpl.
    split.
    + now rewrite israbsorb_zero_multNonnegativeRationals.
    + apply Y_bot with (1 := pr2 (pr2 ry)).
      apply isnonnegative_NonnegativeRationals.
  - set (ny := pr1 ry * (n / r)%NRat).
    exists ny.
    split.
    + unfold ny ; simpl.
      rewrite <- isassoc_multNonnegativeRationals, <- (pr1 (pr2 ry)).
      rewrite multdivNonnegativeRationals.
      reflexivity.
      now apply NonnegativeRationals_neq0_gt0.
    + apply Y_bot with (1 := pr2 (pr2 ry)).
      apply multNonnegativeRationals_le1_r.
      now apply divNonnegativeRationals_le1.
Qed.
Lemma Dcuts_NQmult_open : Dcuts_def_open Dcuts_NQmult_val.
Proof.
  intros r.
  apply hinhuniv ; intros ry.
  generalize (Y_open _ (pr2 (pr2 ry))).
  apply hinhfun.
  intros ny.

  exists (x * pr1 ny).
  split.
  - apply hinhpr ; exists (pr1 ny).
    split.
    + reflexivity.
    + exact (pr1 (pr2 ny)).
  - pattern r at 1 ;  rewrite (pr1 (pr2 ry)).
    apply multNonnegativeRationals_ltcompat_l.
    exact Hx.
    exact (pr2 (pr2 ny)).
Qed.
Lemma Dcuts_NQmult_finite : Dcuts_def_finite Dcuts_NQmult_val.
Proof.
  revert Y_finite.
  apply hinhfun.
  intros y.
  exists (x * pr1 y).
  unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ;
  intros ry.
  generalize (pr1 (pr2 ry)).
  apply gtNonnegativeRationals_noteq.
  apply (pr2 (lt_gtNonnegativeRationals _ _)).
  apply (multNonnegativeRationals_ltcompat_l x (pr1 ry) (pr1 y) Hx).
  apply notge_ltNonnegativeRationals.
  intro Hy' ; apply (pr2 y).
  apply Y_bot with (pr1 ry).
  exact (pr2 (pr2 ry)).
  exact Hy'.
Qed.

Lemma Dcuts_NQmult_error : Dcuts_def_error Dcuts_NQmult_val.
Proof.
  intros c Hc.
  assert (Hcx : (0 < c / x)%NRat) by (now apply ispositive_divNonnegativeRationals).
  generalize (Y_error _ Hcx).
  apply hinhfun ; apply sumofmaps ; intros Hy.
  - left.
    unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ;
    intros ry.
    generalize (pr1 (pr2 ry)).
    apply gtNonnegativeRationals_noteq.
    pattern c at 1 ;
      rewrite <- (multdivNonnegativeRationals c x).
    apply (pr2 (lt_gtNonnegativeRationals _ _)).
    apply (multNonnegativeRationals_ltcompat_l x (pr1 ry) (c / x)%NRat Hx).
    apply notge_ltNonnegativeRationals.
    intro Hy' ; apply Hy.
    apply Y_bot with (pr1 ry).
    exact (pr2 (pr2 ry)).
    exact Hy'.
    exact Hx.
  - right.
    rename Hy into q.
    exists (x * pr1 q).
    split.
    + apply hinhpr.
      exists (pr1 q).
      split.
      reflexivity.
      exact (pr1 (pr2 q)).
    + unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ;
      intros ry.
      generalize (pr1 (pr2 ry)).
      apply gtNonnegativeRationals_noteq.
      pattern c at 2 ;
        rewrite <- (multdivNonnegativeRationals c x), <-isldistr_mult_plusNonnegativeRationals.
      apply (pr2 ( lt_gtNonnegativeRationals _ _)).
      apply (multNonnegativeRationals_ltcompat_l x (pr1 ry) (pr1 q + c / x)%NRat Hx).
      apply notge_ltNonnegativeRationals.
      intro Hy' ; apply (pr2 (pr2 q)).
      apply Y_bot with (pr1 ry).
      exact (pr2 (pr2 ry)).
      exact Hy'.
      exact Hx.
Qed.

End Dcuts_NQmult.

Definition Dcuts_NQmult x (Y : Dcuts) Hx : Dcuts :=
  mk_Dcuts (Dcuts_NQmult_val x (pr1 Y))
           (Dcuts_NQmult_bot x (pr1 Y) (is_Dcuts_bot Y))
           (Dcuts_NQmult_open x Hx (pr1 Y) (is_Dcuts_open Y))
           (Dcuts_NQmult_error x Hx (pr1 Y) (is_Dcuts_bot Y) (is_Dcuts_error Y)).

Section Dcuts_mult.

  Context (X : hsubtypes NonnegativeRationals).
  Context (X_bot : Dcuts_def_bot X).
  Context (X_open : Dcuts_def_open X).
  Context (X_finite : Dcuts_def_finite X).
  Context (X_error : Dcuts_def_error X).
  Context (Y : hsubtypes NonnegativeRationals).
  Context (Y_bot : Dcuts_def_bot Y).
  Context (Y_open : Dcuts_def_open Y).
  Context (Y_finite : Dcuts_def_finite Y).
  Context (Y_error : Dcuts_def_error Y).

Definition Dcuts_mult_val : hsubtypes NonnegativeRationals :=
  fun r => ∃ xy : NonnegativeRationals * NonnegativeRationals,
                           r = (fst xy * snd xy)%NRat × X (fst xy) × Y (snd xy).

Lemma Dcuts_mult_bot : Dcuts_def_bot Dcuts_mult_val.
Proof.
  intros r Hr n Hn.
  revert Hr ; apply hinhfun ;
  intros xy.
  generalize (isdeceq_NonnegativeRationals r 0%NRat) ;
    apply sumofmaps ; intros Hr0.
  - rewrite Hr0 in Hn.
    apply NonnegativeRationals_eq0_le0 in Hn.
    exists (0%NRat,0%NRat).
    rewrite Hn ; simpl.
    repeat split.
    + now rewrite israbsorb_zero_multNonnegativeRationals.
    + apply X_bot with (1 := pr1 (pr2 (pr2 xy))).
      apply isnonnegative_NonnegativeRationals.
    + apply Y_bot with (1 := pr2 (pr2 (pr2 xy))).
      apply isnonnegative_NonnegativeRationals.
  - set (nx := fst (pr1 xy)).
    set (ny := (snd (pr1 xy) * (n / r))%NRat).
    exists (nx,ny).
    repeat split.
    + unfold nx,ny ; simpl.
      rewrite <- isassoc_multNonnegativeRationals, <- (pr1 (pr2 xy)).
      rewrite multdivNonnegativeRationals.
      reflexivity.
      now apply NonnegativeRationals_neq0_gt0.
    + exact (pr1 (pr2 (pr2 xy))).
    + apply Y_bot with (1 := pr2 (pr2 (pr2 xy))).
      apply multNonnegativeRationals_le1_r.
      now apply divNonnegativeRationals_le1.
Qed.
Lemma Dcuts_mult_open : Dcuts_def_open Dcuts_mult_val.
Proof.
  intros r.
  apply hinhuniv ; intros xy.
  generalize (X_open _ (pr1 (pr2 (pr2 xy)))) (Y_open _ (pr2 (pr2 (pr2 xy)))).
  apply hinhfun2.
  intros nx ny.
  exists (pr1 nx * pr1 ny).
  split.
  - apply hinhpr ; exists (pr1 nx , pr1 ny).
    repeat split.
    + exact (pr1 (pr2 nx)).
    + exact (pr1 (pr2 ny)).
  - pattern r at 1 ; rewrite (pr1 (pr2 xy)).
    apply multNonnegativeRationals_ltcompat.
    exact (pr2 (pr2 nx)).
    exact (pr2 (pr2 ny)).
Qed.
Lemma Dcuts_mult_finite : Dcuts_def_finite Dcuts_mult_val.
Proof.
  revert X_finite Y_finite.
  apply hinhfun2.
  intros x y.
  exists (pr1 x * pr1 y).
  unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ;
  intros xy.
  generalize (isdecrel_ltNonnegativeRationals (fst (pr1 xy)) (pr1 x)) ; apply sumofmaps ; intros Hx'.
  generalize (isdecrel_ltNonnegativeRationals (snd (pr1 xy)) (pr1 y)) ; apply sumofmaps ; intros Hy'.
  - apply (isirrefl_StrongOrder ltNonnegativeRationals (pr1 x * pr1 y)).
    pattern (pr1 x * pr1 y) at 1 ; rewrite (pr1 (pr2 xy)).
    now apply multNonnegativeRationals_ltcompat.
  - apply (pr2 y).
    apply Y_bot with (1 := pr2 (pr2 (pr2 xy))).
    now apply notlt_geNonnegativeRationals ; apply Hy'.
  - apply (pr2 x).
    apply X_bot with (1 := pr1 (pr2 (pr2 xy))).
    now apply notlt_geNonnegativeRationals ; apply Hx'.
Qed.

Context (Hx1 : ¬ X 1%NRat).

Lemma Dcuts_mult_error_aux : Dcuts_def_error Dcuts_mult_val.
Proof.
  intros c Hc0.
  apply ispositive_NQhalf in Hc0.
  generalize (Y_error _ Hc0).
  apply hinhuniv ; apply sumofmaps ; intros Hy.
  - apply hinhpr ; left.
    unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ;
    intros xy.
    generalize (pr1 (pr2 xy)).
    apply gtNonnegativeRationals_noteq.
    pattern c at 1 ;
      rewrite <- (islunit_oneNonnegativeRationals c).
    apply multNonnegativeRationals_ltcompat.
    apply notge_ltNonnegativeRationals ; intro H.
    apply Hx1, X_bot with (1 := pr1 (pr2 (pr2 xy))).
    exact H.
    apply notge_ltNonnegativeRationals ; intro H.
    apply Hy, Y_bot with (1 := pr2 (pr2 (pr2 xy))).
    apply istrans_leNonnegativeRationals with (2 := H).
    pattern c at 2 ; rewrite (NQhalf_double c).
    now apply plusNonnegativeRationals_le_r.
  - rename Hy into y.
    assert (Hq1 : (0 < pr1 y + c / 2)%NRat).
    { apply istrans_lt_le_ltNonnegativeRationals with (c / 2)%NRat.
      exact Hc0.
      now apply plusNonnegativeRationals_le_l. }
    set (cx := ((c / 2) / (pr1 y + (c / 2)))%NRat).
    assert (Hcx0 : (0 < cx)%NRat)
      by (now apply ispositive_divNonnegativeRationals).
    generalize (X_error _ Hcx0) ; apply hinhfun ; apply sumofmaps ; intros H.
    + left.
      unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ;
      intros xy.
      generalize (pr1 (pr2 xy)).
      apply gtNonnegativeRationals_noteq.
      apply istrans_ltNonnegativeRationals with (c / 2)%NRat.
      rewrite <- (multdivNonnegativeRationals (c / 2)%NRat (pr1 y + (c / 2)%NRat)).
      rewrite iscomm_multNonnegativeRationals.
      apply multNonnegativeRationals_ltcompat.
      apply notge_ltNonnegativeRationals ; intro H0.
      apply (pr2 (pr2 y)), Y_bot with (1 := pr2 (pr2 (pr2 xy))).
      exact H0.
      apply notge_ltNonnegativeRationals ; intro H0.
      apply H, X_bot with (1 := pr1 (pr2 (pr2 xy))).
      exact H0.
      exact Hq1.
      rewrite <- (islunit_zeroNonnegativeRationals (c / 2)%NRat).
      pattern c at 2 ; rewrite (NQhalf_double c).
      now apply plusNonnegativeRationals_ltcompat_r.
    + right.
      rename H into x.
      exists (pr1 x * pr1 y) ; repeat split.
      * apply hinhpr.
        exists (pr1 x, pr1 y) ; simpl ; repeat split.
        exact (pr1 (pr2 x)).
        exact (pr1 (pr2 y)).
      * unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ;
        intros xy.
        generalize (pr1 (pr2 xy)).
        apply gtNonnegativeRationals_noteq.
        apply istrans_lt_le_ltNonnegativeRationals with ((pr1 x + cx)* (pr1 y + (c / 2)%NRat)).
        apply multNonnegativeRationals_ltcompat.
        apply notge_ltNonnegativeRationals.
        intros H ; apply (pr2 (pr2 x)), X_bot with (1 := pr1 (pr2 (pr2 xy))).
        exact H.
        apply notge_ltNonnegativeRationals.
        intros H ; apply (pr2 (pr2 y)), Y_bot with (1 := pr2 (pr2 (pr2 xy))).
        exact H.
        rewrite isrdistr_mult_plusNonnegativeRationals, (iscomm_multNonnegativeRationals cx).
        unfold cx ; rewrite multdivNonnegativeRationals.
        pattern c at 11 ;
          rewrite (NQhalf_double c), <- isassoc_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_r.
        rewrite isldistr_mult_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_l.
        rewrite iscomm_multNonnegativeRationals.
        apply multNonnegativeRationals_le1_r.
        apply lt_leNonnegativeRationals, notge_ltNonnegativeRationals.
        intro H ; apply Hx1.
        now apply X_bot with (1 := pr1 (pr2 x)).
        exact Hq1.
Qed.

End Dcuts_mult.

Section Dcuts_mult'.

  Context (X : hsubtypes NonnegativeRationals).
  Context (X_bot : Dcuts_def_bot X).
  Context (X_open : Dcuts_def_open X).
  Context (X_finite : Dcuts_def_finite X).
  Context (X_error : Dcuts_def_error X).
  Context (Y : hsubtypes NonnegativeRationals).
  Context (Y_bot : Dcuts_def_bot Y).
  Context (Y_open : Dcuts_def_open Y).
  Context (Y_finite : Dcuts_def_finite Y).
  Context (Y_error : Dcuts_def_error Y).

Lemma Dcuts_mult_error : Dcuts_def_error (Dcuts_mult_val X Y).
Proof.
  intros c Hc.
  generalize (X_error 1%NRat ispositive_oneNonnegativeRationals).
  apply hinhuniv ; apply sumofmaps ; [ intros Hx1 | intros x].
  - now apply Dcuts_mult_error_aux.
  - assert (Hx1 : (0 < pr1 x + 1)%NRat).
    { apply istrans_lt_le_ltNonnegativeRationals with (1 := ispositive_oneNonnegativeRationals).
      apply plusNonnegativeRationals_le_l. }
    assert (Heq : Dcuts_mult_val X Y = (Dcuts_NQmult_val (pr1 x + 1%NRat) (Dcuts_mult_val (Dcuts_NQmult_val (/ (pr1 x + 1))%NRat X) Y))).
    { apply funextfun ; intro r.
      apply hPropUnivalence.
      - apply hinhfun.
        intros xy.
        exists (r / (pr1 x + 1))%NRat ; split.
        + now  rewrite multdivNonnegativeRationals.
        + apply hinhpr.
          exists (fst (pr1 xy) / (pr1 x + 1%NRat),snd (pr1 xy))%NRat ; simpl ; repeat split.
          * unfold divNonnegativeRationals.
            rewrite isassoc_multNonnegativeRationals, (iscomm_multNonnegativeRationals (/ (pr1 x + 1))%NRat).
            rewrite <- isassoc_multNonnegativeRationals.
            now pattern r at 1 ; rewrite (pr1 (pr2 xy)).
          * apply hinhpr.
            exists (fst (pr1 xy)) ; split.
            now apply iscomm_multNonnegativeRationals.
            exact (pr1 (pr2 (pr2 xy))).
          * exact (pr2 (pr2 (pr2 xy))).
      - apply hinhuniv.
        intros rx.
        generalize (pr2 (pr2 rx)) ; apply hinhuniv.
        intros xy.
        generalize (pr1 (pr2 (pr2 xy))) ; apply hinhfun ; intros rx'.
        rewrite (pr1 (pr2 rx)), (pr1 (pr2 xy)), (pr1 (pr2 rx')).
        exists (pr1 rx',snd (pr1 xy)) ; repeat split.
        now rewrite <- !isassoc_multNonnegativeRationals, isrinv_NonnegativeRationals, islunit_oneNonnegativeRationals.
        exact (pr2 (pr2 rx')).
        exact (pr2 (pr2 (pr2 xy))). }
    rewrite Heq.
    revert c Hc.
    apply Dcuts_NQmult_error.
    + exact Hx1.
    + apply Dcuts_mult_bot, Y_bot.
      now apply Dcuts_NQmult_bot.
    + apply Dcuts_mult_error_aux.
      now apply Dcuts_NQmult_bot.
      apply Dcuts_NQmult_error.
      now apply ispositive_invNonnegativeRationals.
      exact X_bot.
      exact X_error.
      exact Y_bot.
      exact Y_error.
      unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ;
      intros rx.
      apply (pr2 (pr2 x)), X_bot with (1 := pr2 (pr2 rx)).
      rewrite <- (isrunit_oneNonnegativeRationals (pr1 x + 1%NRat)).
      pattern 1%NRat at 3 ; rewrite (pr1 (pr2 rx)), <- isassoc_multNonnegativeRationals.
      rewrite isrinv_NonnegativeRationals, islunit_oneNonnegativeRationals.
      now apply isrefl_leNonnegativeRationals.
      exact Hx1.
Qed.

End Dcuts_mult'.

Definition Dcuts_mult (X Y : Dcuts) : Dcuts :=
  mk_Dcuts (Dcuts_mult_val (pr1 X) (pr1 Y))
           (Dcuts_mult_bot (pr1 X) (is_Dcuts_bot X)
                           (pr1 Y) (is_Dcuts_bot Y))
           (Dcuts_mult_open (pr1 X) (is_Dcuts_open X)
                            (pr1 Y) (is_Dcuts_open Y))
           (Dcuts_mult_error (pr1 X) (is_Dcuts_bot X) (is_Dcuts_error X)
                             (pr1 Y) (is_Dcuts_bot Y) (is_Dcuts_error Y)).

(** ** Multiplicative inverse in Dcuts *)

Section Dcuts_inv.

Context (X : hsubtypes NonnegativeRationals).
Context (X_bot : Dcuts_def_bot X).
Context (X_open : Dcuts_def_open X).
Context (X_finite : Dcuts_def_finite X).
Context (X_error : Dcuts_def_error X).
Context (X_0 : X 0%NRat).

Definition Dcuts_inv_val : hsubtypes NonnegativeRationals :=
  λ r : NonnegativeRationals,
        hexists (λ l : NonnegativeRationals, (Π rx : NonnegativeRationals, X rx -> (r * rx <= l)%NRat)
                                               × (0 < l)%NRat × (l < 1)%NRat).

Lemma Dcuts_inv_in :
  Π x, (0 < x)%NRat -> X x -> (Dcuts_inv_val (/ x)%NRat) -> empty.
Proof.
  intros x Hx0 Xx.
  unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; intros l.
  set (H := pr1 (pr2 l) _ Xx).
  rewrite islinv_NonnegativeRationals in H.
  apply (pr2 (notlt_geNonnegativeRationals _ _)) in H.
  now apply H, (pr2 (pr2 (pr2 l))).
  exact Hx0.
Qed.
Lemma Dcuts_inv_out :
  Π x, ¬ (X x) -> Π y, (x < y)%NRat -> Dcuts_inv_val (/ y)%NRat.
Proof.
  intros x nXx y Hy.
  apply hinhpr.
  exists (x / y)%NRat ; repeat split.
  - intros rx Hrx.
    unfold divNonnegativeRationals.
    rewrite iscomm_multNonnegativeRationals.
    apply multNonnegativeRationals_lecompat_r.
    apply lt_leNonnegativeRationals, notge_ltNonnegativeRationals.
    intros H ; apply nXx.
    now apply X_bot with (1 := Hrx).
  - apply ispositive_divNonnegativeRationals.
    apply notge_ltNonnegativeRationals.
    intros H ; apply nXx.
    now apply X_bot with (1 := X_0).
    apply istrans_le_lt_ltNonnegativeRationals with (2 := Hy).
    now apply isnonnegative_NonnegativeRationals.
  - apply_pr2 (multNonnegativeRationals_ltcompat_r y).
    apply istrans_le_lt_ltNonnegativeRationals with (2 := Hy).
    now apply isnonnegative_NonnegativeRationals.
    unfold divNonnegativeRationals.
    rewrite isassoc_multNonnegativeRationals, islinv_NonnegativeRationals, islunit_oneNonnegativeRationals, isrunit_oneNonnegativeRationals.
    exact Hy.
    apply istrans_le_lt_ltNonnegativeRationals with (2 := Hy).
    now apply isnonnegative_NonnegativeRationals.
Qed.

Lemma Dcuts_inv_bot : Dcuts_def_bot Dcuts_inv_val.
Proof.
  intros r Hr q Hq.
  revert Hr.
  apply hinhfun ; intros l.
  exists (pr1 l) ; repeat split.
  - intros rx Xrx.
    apply istrans_leNonnegativeRationals with (2 := pr1 (pr2 l) _ Xrx).
    now apply multNonnegativeRationals_lecompat_r.
  - exact (pr1 (pr2 (pr2 l))).
  - exact (pr2 (pr2 (pr2 l))).
Qed.

Lemma Dcuts_inv_open : Dcuts_def_open Dcuts_inv_val.
Proof.
  intros r.
  apply hinhuniv.
  intros l.
  generalize (eq0orgt0NonnegativeRationals r) ; apply sumofmaps ; intros Hr0.
  - rewrite Hr0 in l |- * ; clear r Hr0.
    revert X_finite.
    apply hinhfun.
    intros r'.
    set (r := NQmax 2%NRat (pr1 r')).
    assert (Hr1 : (1 < r)%NRat).
    { apply istrans_lt_le_ltNonnegativeRationals with (2 := NQmax_le_l _ _).
      exact one_lt_twoNonnegativeRationals. }
    assert (Hr0 : (0 < r)%NRat).
    { simple refine (istrans_le_lt_ltNonnegativeRationals _ _ _ _ Hr1).
      now apply isnonnegative_NonnegativeRationals. }
    exists (/ (r * r))%NRat ; split.
    + apply hinhpr.
      exists (/ r)%NRat ; repeat split.
      * intros rx Xrx.
        apply (multNonnegativeRationals_lecompat_l' (r * r)).
        now apply ispositive_multNonnegativeRationals.
        rewrite <- isassoc_multNonnegativeRationals, isrinv_NonnegativeRationals, islunit_oneNonnegativeRationals.
        rewrite isassoc_multNonnegativeRationals, isrinv_NonnegativeRationals, isrunit_oneNonnegativeRationals.
        apply istrans_leNonnegativeRationals with (2 := NQmax_le_r _ _).
        apply lt_leNonnegativeRationals, notge_ltNonnegativeRationals ; intro H ; apply (pr2 r').
        now apply X_bot with (1 := Xrx).
        exact Hr0.
        now apply ispositive_multNonnegativeRationals.
      * now apply ispositive_invNonnegativeRationals.
      * apply_pr2 (multNonnegativeRationals_ltcompat_l r).
        easy.
        now rewrite isrinv_NonnegativeRationals, isrunit_oneNonnegativeRationals.
    + apply ispositive_invNonnegativeRationals.
      now apply ispositive_multNonnegativeRationals.
  - set (l' := between_ltNonnegativeRationals _ _ (pr2 (pr2 (pr2 l)))).
    apply hinhpr.
    exists ((pr1 l'/pr1 l) * r)%NRat ; split.
    + apply hinhpr.
      exists (pr1 l') ; repeat split.
      * intros rx Xrx.
        rewrite isassoc_multNonnegativeRationals.
        pattern l' at 1 ;
          rewrite <- (multdivNonnegativeRationals (pr1 l') (pr1 l)), iscomm_multNonnegativeRationals.
        apply multNonnegativeRationals_lecompat_r.
        now apply (pr1 (pr2 l)).
        exact (pr1 (pr2 (pr2 l))).
      * apply istrans_le_lt_ltNonnegativeRationals with (2 := pr1 (pr2 l')).
        now apply isnonnegative_NonnegativeRationals.
      * exact (pr2 (pr2 l')).
    + pattern r at 1 ; rewrite <- (islunit_oneNonnegativeRationals r).
      apply multNonnegativeRationals_ltcompat_r.
      exact Hr0.
      apply_pr2 (multNonnegativeRationals_ltcompat_r (pr1 l)).
      exact (pr1 (pr2 (pr2 l))).
      rewrite islunit_oneNonnegativeRationals.
      rewrite iscomm_multNonnegativeRationals, multdivNonnegativeRationals.
      exact (pr1 (pr2 l')).
      exact (pr1 (pr2 (pr2 l))).
Qed.

Context (X_1 : X 1%NRat).

Lemma Dcuts_inv_error_aux : Dcuts_def_error Dcuts_inv_val.
Proof.
  assert (Π c, (0 < c)%NRat -> hexists (λ q : NonnegativeRationals, X q × ¬ X (q + c))).
  { intros c Hc0.
    generalize (X_error c Hc0) ; apply hinhuniv ; apply sumofmaps ; [ intros nXc | intros H].
    - apply hinhpr.
      exists 0%NRat ; split.
      + exact X_0.
      + now rewrite islunit_zeroNonnegativeRationals.
    - apply hinhpr ; exact H. }
  clear X_error ; rename X0 into X_error.

  intros c Hc0.
  apply ispositive_NQhalf in Hc0.
  specialize (X_error _ Hc0) ; revert X_error.
  apply hinhfun ; intros r.
  right.
  exists (/ (NQmax 1%NRat (pr1 r) + c))%NRat ; split.
  - apply Dcuts_inv_out with (1 := pr2 (pr2 r)).
    pattern c at 4 ; rewrite (NQhalf_double c), <- isassoc_plusNonnegativeRationals.
    eapply istrans_le_lt_ltNonnegativeRationals, plusNonnegativeRationals_lt_r.
    apply plusNonnegativeRationals_lecompat_r ; apply NQmax_le_r.
    exact Hc0.
  - assert (Xmax : X (NQmax 1%NRat (pr1 r))).
    { apply NQmax_case.
      exact X_1.
      exact (pr1 (pr2 r)). }
    assert (Hmax : (0 < NQmax 1 (pr1 r))%NRat).
    { eapply istrans_lt_le_ltNonnegativeRationals, NQmax_le_l.
      now eapply ispositive_oneNonnegativeRationals. }
    intro Hinv ; apply (Dcuts_inv_in _ Hmax Xmax), Dcuts_inv_bot with (1 := Hinv).
    apply lt_leNonnegativeRationals, minusNonnegativeRationals_ltcompat_l' with (/ (NQmax 1 (pr1 r) + c))%NRat.
    rewrite plusNonnegativeRationals_minus_l.
    rewrite minus_divNonnegativeRationals, plusNonnegativeRationals_minus_l.
    unfold divNonnegativeRationals ;
      apply_pr2 (multNonnegativeRationals_ltcompat_r (NQmax 1 (pr1 r) * (NQmax 1 (pr1 r) + c))%NRat).
    apply ispositive_multNonnegativeRationals.
    exact Hmax.
    now apply ispositive_plusNonnegativeRationals_l.
    rewrite isassoc_multNonnegativeRationals, islinv_NonnegativeRationals.
    apply multNonnegativeRationals_ltcompat_l.
    now apply_pr2 ispositive_NQhalf.
    pattern 1%NRat at 1 ;
      rewrite <- (islunit_oneNonnegativeRationals 1%NRat).
    apply istrans_le_lt_ltNonnegativeRationals with (NQmax 1 (pr1 r) * 1)%NRat.
    now apply multNonnegativeRationals_lecompat_r, NQmax_le_l.
    apply multNonnegativeRationals_ltcompat_l.
    exact Hmax.
    apply istrans_le_lt_ltNonnegativeRationals with (1 := NQmax_le_l _ (pr1 r)).
    apply plusNonnegativeRationals_lt_r.
    now apply_pr2 ispositive_NQhalf.
    apply ispositive_multNonnegativeRationals.
    exact Hmax.
    now apply ispositive_plusNonnegativeRationals_l.
    now apply ispositive_plusNonnegativeRationals_l.
Qed.

End Dcuts_inv.

Section Dcuts_inv'.

Context (X : hsubtypes NonnegativeRationals).
Context (X_bot : Dcuts_def_bot X).
Context (X_open : Dcuts_def_open X).
Context (X_finite : Dcuts_def_finite X).
Context (X_error : Dcuts_def_error X).
Context (X_0 : X 0%NRat).

Lemma Dcuts_inv_error : Dcuts_def_error (Dcuts_inv_val X).
Proof.
  generalize (X_open _ X_0) ; apply (hinhuniv (P := hProppair _ (isaprop_Dcuts_def_error _))) ; intros x.
  set (Y := Dcuts_NQmult_val (/ (pr1 x))%NRat X).
  assert (Y_1 : Y 1%NRat).
  { unfold Y ; apply hinhpr ; exists (pr1 x) ; split.
    apply pathsinv0, islinv_NonnegativeRationals.
    exact (pr2 (pr2 x)).
    exact (pr1 (pr2 x)). }
  assert (Heq : Dcuts_inv_val X = Dcuts_NQmult_val (/(pr1 x))%NRat (Dcuts_inv_val Y)).
  { apply funextfun ; intro r.
    apply hPropUnivalence.
    - apply hinhfun ; intros l.
      exists (pr1 x * r) ; split.
      rewrite <- isassoc_multNonnegativeRationals, islinv_NonnegativeRationals, islunit_oneNonnegativeRationals.
      reflexivity.
      exact (pr2 (pr2 x)).
      apply hinhpr.
      exists (pr1 l) ; repeat split.
      intros q ; unfold Y.
      apply hinhuniv ; intros s.
      rewrite (pr1 (pr2 s)).
      rewrite (iscomm_multNonnegativeRationals (pr1 x)), <- isassoc_multNonnegativeRationals.
      rewrite iscomm_multNonnegativeRationals, !isassoc_multNonnegativeRationals, isrinv_NonnegativeRationals, isrunit_oneNonnegativeRationals, iscomm_multNonnegativeRationals.
      apply (pr1 (pr2 l)).
      exact (pr2 (pr2 s)).
      exact (pr2 (pr2 x)).
      exact (pr1 (pr2 (pr2 l))).
      exact (pr2 (pr2 (pr2 l))).
    - apply hinhuniv. intros q.
      rewrite (pr1 (pr2 q)).
      generalize (pr2 (pr2 q)).
      apply hinhfun ; intros l.
      exists (pr1 l) ; repeat split.
      intros s Xs.
      rewrite (iscomm_multNonnegativeRationals (/ pr1 x)%NRat), isassoc_multNonnegativeRationals.
      apply (pr1 (pr2 l)).
      unfold Y ; apply hinhpr.
      now exists s.
      exact (pr1 (pr2 (pr2 l))).
      exact (pr2 (pr2 (pr2 l))). }
  rewrite Heq.
  apply Dcuts_NQmult_error.
  apply ispositive_invNonnegativeRationals.
  exact (pr2 (pr2 x)).
  now apply Dcuts_inv_bot.
  apply Dcuts_inv_error_aux.
  now unfold Y ; apply Dcuts_NQmult_bot.
  unfold Y ; apply Dcuts_NQmult_error.
  apply ispositive_invNonnegativeRationals.
  exact (pr2 (pr2 x)).
  exact X_bot.
  exact X_error.
  apply hinhpr ; exists 0%NRat ; split.
  now rewrite israbsorb_zero_multNonnegativeRationals.
  exact X_0.
  exact Y_1.
Qed.

End Dcuts_inv'.

Definition Dcuts_inv (X : Dcuts) (X_0 : X ≠ 0) : Dcuts.
Proof.
  intros.
  apply (mk_Dcuts (Dcuts_inv_val (pr1 X))).
  - now apply Dcuts_inv_bot.
  - apply Dcuts_inv_open.
    now apply is_Dcuts_bot.
    now apply Dcuts_def_error_finite, is_Dcuts_error.
  - apply Dcuts_inv_error.
    now apply is_Dcuts_bot.
    now apply is_Dcuts_open.
    now apply is_Dcuts_error.
    now apply_pr2 Dcuts_apzero_notempty.
Defined.

(** ** Algebraic properties *)

Lemma Dcuts_NQmult_mult :
  Π (x : NonnegativeRationals) (y : Dcuts) (Hx0 : (0 < x)%NRat), Dcuts_NQmult x y Hx0 = Dcuts_mult (NonnegativeRationals_to_Dcuts x) y.
Proof.
  intros x y Hx0.
  apply Dcuts_eq_is_eq.
  intros r ; split.
  - apply hinhuniv.
    intros ry.
    generalize (is_Dcuts_open _ _ (pr2 (pr2 ry))).
    apply hinhfun ; intros ry'.
    exists (((x * (pr1 ry)) / (pr1 ry'))%NRat, (pr1 ry')).
    simpl.
    assert (Hry' : (0 < pr1 ry')%NRat).
    { eapply istrans_le_lt_ltNonnegativeRationals, (pr2 (pr2 ry')).
      apply isnonnegative_NonnegativeRationals. }
    split ; [ | split].
    + unfold divNonnegativeRationals.
      rewrite isassoc_multNonnegativeRationals, islinv_NonnegativeRationals, isrunit_oneNonnegativeRationals.
      exact (pr1 (pr2 ry)).
      exact Hry'.
    + pattern x at 4.
      rewrite <- (isrunit_oneNonnegativeRationals x).
      unfold divNonnegativeRationals.
      rewrite isassoc_multNonnegativeRationals.
      apply multNonnegativeRationals_ltcompat_l.
      exact Hx0.
      rewrite <- (isrinv_NonnegativeRationals (pr1 ry')).
      apply multNonnegativeRationals_ltcompat_r.
      apply ispositive_invNonnegativeRationals.
      exact Hry'.
      exact (pr2 (pr2 ry')).
      exact Hry'.
    + exact (pr1 (pr2 ry')).
  - apply hinhfun ; simpl.
    intros xy.
    exists (fst (pr1 xy) * snd (pr1 xy) / x).
    split.
    + rewrite iscomm_multNonnegativeRationals.
      unfold divNonnegativeRationals.
      rewrite isassoc_multNonnegativeRationals, islinv_NonnegativeRationals, isrunit_oneNonnegativeRationals.
      exact (pr1 (pr2 xy)).
      exact Hx0.
    + apply is_Dcuts_bot with (1 := pr2 (pr2 (pr2 xy))).
      pattern (snd (pr1 xy)) at 2.
      rewrite <- (isrunit_oneNonnegativeRationals (snd (pr1 xy))), <- (isrinv_NonnegativeRationals x), <- isassoc_multNonnegativeRationals.
      apply multNonnegativeRationals_lecompat_r.
      rewrite iscomm_multNonnegativeRationals.
      apply multNonnegativeRationals_lecompat_l.
      apply lt_leNonnegativeRationals.
      exact (pr1 (pr2 (pr2 xy))).
      exact Hx0.
Qed.

Lemma iscomm_Dcuts_plus : iscomm Dcuts_plus.
Proof.
  assert (H : Π x y, Π x0 : NonnegativeRationals, x0 ∈ Dcuts_plus x y -> x0 ∈ Dcuts_plus y x).
  { intros x y r.
    apply hinhuniv, sumofmaps ; simpl pr1.
    - apply sumofmaps ; intros Hr.
      + now apply hinhpr ; left ; right.
      + now apply hinhpr ; left ; left.
    - intros xy.
      apply hinhpr ; right ; exists (pr2 (pr1 xy),, pr1 (pr1 xy)).
      repeat split.
      + pattern r at 1 ; rewrite (pr1 (pr2 xy)).
        apply iscomm_plusNonnegativeRationals.
      + exact (pr2 (pr2 (pr2 xy))).
      + exact (pr1 (pr2 (pr2 xy))).
  }
  intros x y.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - now apply H.
  - now apply H.
Qed.

Lemma Dcuts_plus_lt_l :
  Π x x' y : Dcuts, Dcuts_plus x y < Dcuts_plus x' y -> x < x'.
Proof.
  intros x x' y.
  apply hinhuniv ; intros r.
  generalize (pr2 (pr2 r)) ; apply hinhfun ; apply sumofmaps ;
  [ apply sumofmaps ; [ intros Xr | intros Yr] | intros xy ].
  - exists (pr1 r) ; split.
    intro H ; apply (pr1 (pr2 r)).
    now apply hinhpr ; left ; left.
    exact Xr.
  - apply fromempty, (pr1 (pr2 r)).
    now apply hinhpr ; left ; right.
  - exists (pr1 (pr1 xy)) ; split.
    intro H ; apply (pr1 (pr2 r)).
    apply hinhpr ; right ; exists (pr1 xy).
    repeat split.
    exact (pr1 (pr2 xy)).
    exact H.
    exact (pr2 (pr2 (pr2 xy))).
    exact (pr1 (pr2 (pr2 xy))).
Qed.

Lemma islapbinop_Dcuts_plus : islapbinop Dcuts_plus.
Proof.
  intros y x x'.
  apply sumofmaps ; intros Hlt.
  - left.
    now apply Dcuts_plus_lt_l with y.
  - right.
    now apply Dcuts_plus_lt_l with y.
Qed.
Lemma israpbinop_Dcuts_plus : israpbinop Dcuts_plus.
Proof.
  intros x y y'.
  rewrite !(iscomm_Dcuts_plus x).
  now apply islapbinop_Dcuts_plus.
Qed.

Lemma iscomm_Dcuts_mult : iscomm Dcuts_mult.
Proof.
  intros x y.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - apply hinhfun. intros xy.
    exists (snd (pr1 xy),fst (pr1 xy)) ; repeat split.
    rewrite iscomm_multNonnegativeRationals.
    exact (pr1 (pr2 xy)).
    exact (pr2 (pr2 (pr2 xy))).
    exact (pr1 (pr2 (pr2 xy))).
  - apply hinhfun ; intros xy.
    exists (snd (pr1 xy), fst (pr1 xy)) ; repeat split.
    rewrite iscomm_multNonnegativeRationals.
    exact (pr1 (pr2 xy)).
    exact (pr2 (pr2 (pr2 xy))).
    exact (pr1 (pr2 (pr2 xy))).
Qed.

Lemma Dcuts_mult_lt_l :
  Π x x' y : Dcuts, Dcuts_mult x y < Dcuts_mult x' y -> x < x'.
Proof.
  intros x x' y.
  apply hinhuniv ; intros r.
  generalize (pr2 (pr2 r)).
  apply hinhfun ; intros xy.
  exists (fst (pr1 xy)) ; split.
  intro H ; apply (pr1 (pr2 r)).
  apply hinhpr ; exists (pr1 xy).
  repeat split.
  exact (pr1 (pr2 xy)).
  exact H.
  exact (pr2 (pr2 (pr2 xy))).
  exact (pr1 (pr2 (pr2 xy))).
Qed.
Lemma islapbinop_Dcuts_mult : islapbinop Dcuts_mult.
Proof.
  intros y x x'.
  apply sumofmaps.
  intros Hlt.
  - left.
    now apply Dcuts_mult_lt_l with y.
  - right.
    now apply Dcuts_mult_lt_l with y.
Qed.
Lemma israpbinop_Dcuts_mult : israpbinop Dcuts_mult.
Proof.
  intros x y y'.
  rewrite !(iscomm_Dcuts_mult x).
  now apply islapbinop_Dcuts_mult.
Qed.

Lemma isassoc_Dcuts_plus : isassoc Dcuts_plus.
Proof.
  intros x y z.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - apply hinhuniv, sumofmaps ; simpl pr1.
    + apply sumofmaps.
      * apply hinhuniv, sumofmaps.
        { apply sumofmaps ; intros Hr.
          - now apply hinhpr ; left ; left.
          - apply hinhpr ; left ; right.
            now apply hinhpr ; left ; left. }
        { intros xy.
          apply hinhpr ; right ; exists (pr1 xy).
          repeat split.
          - exact (pr1 (pr2 xy)).
          - exact (pr1 (pr2 (pr2 xy))).
          - apply hinhpr ; left ; left.
            exact (pr2 (pr2 (pr2 xy))). }
      * intros Hr.
        apply hinhpr ; left ; right.
        now apply hinhpr ; left ; right.
    + intros xyz.
      generalize (pr1 (pr2 (pr2 xyz))) ; apply hinhuniv, sumofmaps.
      * apply sumofmaps ; intros Hxy.
        { apply hinhpr ; right ; exists (pr1 xyz).
          repeat split.
          - exact (pr1 (pr2 xyz)).
          - exact Hxy.
          - apply hinhpr ; left ; right.
            exact (pr2 (pr2 (pr2 xyz))). }
        { apply hinhpr ; left ; right.
          apply hinhpr ; right ; exists (pr1 xyz).
          repeat split.
          - exact (pr1 (pr2 xyz)).
          - exact Hxy.
          - exact (pr2 (pr2 (pr2 xyz))). }
      * intros xy.
        apply hinhpr ; right ; exists (pr1 (pr1 xy),,pr2 (pr1 xy) + pr2 (pr1 xyz)).
        repeat split ; simpl.
        { pattern r at 1 ; rewrite (pr1 (pr2 xyz)), (pr1 (pr2 xy)).
          now apply isassoc_plusNonnegativeRationals. }
        { exact (pr1 (pr2 (pr2 xy))). }
        { apply hinhpr ; right ; exists (pr2 (pr1 xy),,pr2 (pr1 xyz)).
          repeat split.
          - exact (pr2 (pr2 (pr2 xy))).
          - exact (pr2 (pr2 (pr2 xyz))). }
  - apply hinhuniv, sumofmaps.
    + apply sumofmaps.
      * intros Hr.
        apply hinhpr ; left ; left.
        now apply hinhpr ; left ; left.
      * apply hinhuniv, sumofmaps.
        { apply sumofmaps ; intros Hr.
          - apply hinhpr ; left ; left.
            now apply hinhpr ; left ; right.
          - now apply hinhpr ; left ; right. }
        { intros yz ; simpl in * |-.
          apply hinhpr ; right ; exists (pr1 yz).
          repeat split.
          - exact (pr1 (pr2 yz)).
          - apply hinhpr ; left ; right.
            exact (pr1 (pr2 (pr2 yz))).
          - exact (pr2 (pr2 (pr2 yz))). }
    + intros xyz.
      generalize (pr2 (pr2 (pr2 xyz))) ; apply hinhuniv, sumofmaps.
      * apply sumofmaps ; intros Hyz.
        { apply hinhpr ; left ; left.
          apply hinhpr ; right ; exists (pr1 xyz).
          repeat split.
          - exact (pr1 (pr2 xyz)).
          - exact (pr1 (pr2 (pr2 xyz))).
          - exact Hyz. }
        { apply hinhpr ; right ; exists (pr1 xyz).
          repeat split.
          - exact (pr1 (pr2 xyz)).
          - apply hinhpr ; left ; left.
            exact (pr1 (pr2 (pr2 xyz))).
          - exact Hyz. }
      * intros yz.
        apply hinhpr ; right ; exists ((pr1 (pr1 xyz)+ pr1 (pr1 yz),, pr2 (pr1 yz))).
        repeat split ; simpl.
        { pattern r at 1 ; rewrite (pr1 (pr2 xyz)), (pr1 (pr2 yz)).
          now rewrite isassoc_plusNonnegativeRationals. }
        { apply hinhpr ; right ; exists (pr1 (pr1 xyz),,(pr1 (pr1 yz))).
          repeat split.
          - exact (pr1 (pr2 (pr2 xyz))).
          - exact (pr1 (pr2 (pr2 yz))). }
        { exact (pr2 (pr2 (pr2 yz))). }
Qed.
Lemma islunit_Dcuts_plus_zero : islunit Dcuts_plus 0.
Proof.
  intros x.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - apply hinhuniv, sumofmaps.
    + apply sumofmaps ; intro Hr.
      * now apply Dcuts_zero_empty in Hr.
      * exact Hr.
    + intros x0.
      apply fromempty.
      exact (Dcuts_zero_empty _ (pr1 (pr2 (pr2 x0)))).
  - intros Hr.
    now apply hinhpr ; left ; right.
Qed.
Lemma isrunit_Dcuts_plus_zero : isrunit Dcuts_plus 0.
Proof.
  intros x.
  rewrite iscomm_Dcuts_plus.
  now apply islunit_Dcuts_plus_zero.
Qed.
Lemma isassoc_Dcuts_mult : isassoc Dcuts_mult.
Proof.
  intros x y z.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - apply hinhuniv ; intros xyz.
    generalize (pr1 (pr2 (pr2 xyz))).
    apply hinhfun ; intros xy.
    pattern r at 1 ; rewrite (pr1 (pr2 xyz)), (pr1 (pr2 xy)), isassoc_multNonnegativeRationals.
    exists (fst (pr1 xy),(snd (pr1 xy) * snd (pr1 xyz))) ; simpl ; repeat split.
    + exact (pr1 (pr2 (pr2 xy))).
    + apply hinhpr ; exists (snd (pr1 xy),snd (pr1 (xyz))).
      repeat split.
      exact (pr2 (pr2 (pr2 xy))).
      exact (pr2 (pr2 (pr2 xyz))).
  - apply hinhuniv ; intros xyz.
    generalize (pr2 (pr2 (pr2 xyz))).
    apply hinhfun ; intros yz.
    pattern r at 1 ; rewrite (pr1 (pr2 xyz)), (pr1 (pr2 yz)), <- isassoc_multNonnegativeRationals.
    exists ((fst (pr1 xyz) * fst (pr1 yz)) , snd (pr1 yz)) ; simpl ; repeat split.
    + apply hinhpr ; exists (fst (pr1 xyz),fst (pr1 yz)).
      repeat split.
      exact (pr1 (pr2 (pr2 xyz))).
      exact (pr1 (pr2 (pr2 yz))).
    + exact (pr2 (pr2 (pr2 yz))).
Qed.
Lemma islunit_Dcuts_mult_one : islunit Dcuts_mult Dcuts_one.
Proof.
  intros x.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - apply hinhuniv ; intros ix.
    apply is_Dcuts_bot with (1 := pr2 (pr2 (pr2 ix))).
    pattern r at 1 ; rewrite (pr1 (pr2 ix)), iscomm_multNonnegativeRationals.
    apply multNonnegativeRationals_le1_r, lt_leNonnegativeRationals.
    exact (pr1 (pr2 (pr2 ix))).
  - intros Xr.
    generalize (is_Dcuts_open x r Xr).
    apply hinhfun ; intros q.
    exists ((r/pr1 q)%NRat,pr1 q) ; repeat split.
    + simpl.
      rewrite iscomm_multNonnegativeRationals, multdivNonnegativeRationals.
      reflexivity.
      apply istrans_le_lt_ltNonnegativeRationals with (2 := pr2 (pr2 q)).
      apply isnonnegative_NonnegativeRationals.
    +  change (r / pr1 q < 1)%NRat.
       apply_pr2 (multNonnegativeRationals_ltcompat_l (pr1 q)).
       apply istrans_le_lt_ltNonnegativeRationals with (2 := pr2 (pr2 q)).
       apply isnonnegative_NonnegativeRationals.
       rewrite multdivNonnegativeRationals, isrunit_oneNonnegativeRationals.
       exact (pr2 (pr2 q)).
       apply istrans_le_lt_ltNonnegativeRationals with (2 := pr2 (pr2 q)).
       apply isnonnegative_NonnegativeRationals.
    + exact (pr1 (pr2 q)).
Qed.
Lemma isrunit_Dcuts_mult_one : isrunit Dcuts_mult Dcuts_one.
Proof.
  intros x.
  rewrite iscomm_Dcuts_mult.
  now apply islunit_Dcuts_mult_one.
Qed.
Lemma islabsorb_Dcuts_mult_zero :
  Π x : Dcuts, Dcuts_mult Dcuts_zero x = Dcuts_zero.
Proof.
  intros x.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - apply hinhuniv ; intros ix.
    apply fromempty.
    now apply (Dcuts_zero_empty _ (pr1 (pr2 (pr2 ix)))).
  - intro Hr.
    now apply Dcuts_zero_empty in Hr.
Qed.
Lemma israbsorb_Dcuts_mult_zero :
  Π x : Dcuts, Dcuts_mult x Dcuts_zero = Dcuts_zero.
Proof.
  intros x.
  rewrite iscomm_Dcuts_mult.
  now apply islabsorb_Dcuts_mult_zero.
Qed.
Lemma isldistr_Dcuts_plus_mult : isldistr Dcuts_plus Dcuts_mult.
Proof.
  intros x y z.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - apply hinhuniv ; intros xyz.
    rewrite (pr1 (pr2 xyz)).
    generalize (pr2 (pr2 (pr2 xyz))).
    apply hinhfun ; apply sumofmaps ;
    [ apply sumofmaps ; [intros Xr | intros Yr]
    | intros xy ].
    + left ; left ; apply hinhpr.
      exists (pr1 xyz) ; repeat split.
      exact (pr1 (pr2 (pr2 xyz))).
      exact Xr.
    + left ; right ; apply hinhpr.
      exists (pr1 xyz) ; repeat split.
      exact (pr1 (pr2 (pr2 xyz))).
      exact Yr.
    + rewrite (pr1 (pr2 xy)), isldistr_mult_plusNonnegativeRationals.
      right ;
        exists (fst (pr1 xyz) * pr1 (pr1 xy),, fst (pr1 xyz) * pr2 (pr1 xy)) ; repeat split.
      * apply hinhpr ; exists (fst (pr1 xyz),pr1 (pr1 xy)).
        repeat split.
        exact (pr1 (pr2 (pr2 xyz))).
        exact (pr1 (pr2 (pr2 xy))).
      * apply hinhpr ; exists (fst (pr1 xyz),pr2 (pr1 xy)).
        repeat split.
        exact (pr1 (pr2 (pr2 xyz))).
        exact (pr2 (pr2 (pr2 xy))).
  - apply hinhuniv ; apply sumofmaps ;
    [ apply sumofmaps | intros zxzy ].
    + apply hinhfun ; intros zx.
      rewrite (pr1 (pr2 zx)).
      exists (pr1 zx) ; repeat split.
      * exact (pr1 (pr2 (pr2 zx))).
      * apply hinhpr ; left ; left.
        exact (pr2 (pr2 (pr2 zx))).
    + apply hinhfun ; intros zy.
      rewrite (pr1 (pr2 zy)).
      exists (pr1 zy) ; repeat split.
      * exact (pr1 (pr2 (pr2 zy))).
      * apply hinhpr ; left ; right.
        exact (pr2 (pr2 (pr2 zy))).
    + rewrite (pr1 (pr2 zxzy)).
      generalize (pr1 (pr2 (pr2 zxzy))) (pr2 (pr2 (pr2 zxzy))).
      apply hinhfun2 ; intros zx zy.
      rewrite (pr1 (pr2 zx)), (pr1 (pr2 zy)).
      generalize (isdecrel_leNonnegativeRationals (NQmax (fst (pr1 zx)) (fst (pr1 zy))) 0%NRat) ; apply sumofmaps ; [intros Heq| intros Hlt].
      apply NonnegativeRationals_eq0_le0 in Heq.
      * apply NQmax_eq_zero in Heq.
        rewrite (pr1 Heq), (pr2 Heq).
        exists (0%NRat,snd (pr1 zx)) ; simpl ; repeat split.
        rewrite !islabsorb_zero_multNonnegativeRationals.
        now apply isrunit_zeroNonnegativeRationals.
        apply (is_Dcuts_bot _ _ (pr1 (pr2 (pr2 zx)))).
        apply isnonnegative_NonnegativeRationals.
        apply hinhpr ; left ; left.
        exact (pr2 (pr2 (pr2 zx))).
      * apply notge_ltNonnegativeRationals in Hlt.
        exists (NQmax (fst (pr1 zx)) (fst (pr1 zy)), (fst (pr1 zx) * snd (pr1 zx) / NQmax (fst (pr1 zx)) (fst (pr1 zy)) + (fst (pr1 zy) * snd (pr1 zy) / NQmax (fst (pr1 zx)) (fst (pr1 zy))))) ;
          simpl ; repeat split.
        unfold divNonnegativeRationals.
        rewrite <- isrdistr_mult_plusNonnegativeRationals.
        now apply pathsinv0, multdivNonnegativeRationals.
        apply NQmax_case.
        exact (pr1 (pr2 (pr2 zx))).
        exact (pr1 (pr2 (pr2 zy))).
        apply hinhpr ; right.
        exists (fst (pr1 zx) * snd (pr1 zx) / NQmax (fst (pr1 zx)) (fst (pr1 zy)) ,,
   fst (pr1 zy) * snd (pr1 zy) / NQmax (fst (pr1 zx)) (fst (pr1 zy))) ; simpl ; repeat split.
        apply is_Dcuts_bot with (1 := pr2 (pr2 (pr2 zx))).
        rewrite iscomm_multNonnegativeRationals.
        unfold divNonnegativeRationals ;
          rewrite isassoc_multNonnegativeRationals.
        apply multNonnegativeRationals_le1_r, divNonnegativeRationals_le1.
        now apply NQmax_le_l.
        apply is_Dcuts_bot with (1 := pr2 (pr2 (pr2 zy))).
        rewrite iscomm_multNonnegativeRationals.
        unfold divNonnegativeRationals ;
          rewrite isassoc_multNonnegativeRationals.
        apply multNonnegativeRationals_le1_r, divNonnegativeRationals_le1.
        now apply NQmax_le_r.
Qed.
Lemma isrdistr_Dcuts_plus_mult : isrdistr Dcuts_plus Dcuts_mult.
Proof.
  intros x y z.
  rewrite <- ! (iscomm_Dcuts_mult z).
  now apply isldistr_Dcuts_plus_mult.
Qed.

Lemma Dcuts_ap_one_zero : 1 ≠ 0.
Proof.
  apply isapfun_NonnegativeRationals_to_Dcuts'.
  apply gtNonnegativeRationals_noteq.
  exact ispositive_oneNonnegativeRationals.
Qed.
Definition islinv_Dcuts_inv :
  Π x : Dcuts, Π Hx0 : x ≠ 0, Dcuts_mult (Dcuts_inv x Hx0) x = 1.
Proof.
  intros x Hx0.
  apply Dcuts_eq_is_eq ; intros q ; split.
  - apply hinhuniv ; intros xy.
    rewrite (pr1 (pr2 xy)).
    generalize (pr1 (pr2 (pr2 xy))).
    apply hinhuniv ; intros l.
    change (fst (pr1 xy) * snd (pr1 xy) < 1)%NRat.
    apply istrans_le_lt_ltNonnegativeRationals with (pr1 l).
    apply (pr1 (pr2 l)).
    exact (pr2 (pr2 (pr2 xy))).
    exact (pr2 (pr2 (pr2 l))).
  - change (q ∈ 1) with (q < 1)%NRat ; intro Hq.
    generalize Hx0 ; intro Hx.
    apply_pr2_in Dcuts_apzero_notempty Hx0.
    generalize (eq0orgt0NonnegativeRationals q) ; apply sumofmaps ; intros Hq0.
    + rewrite Hq0.
      apply hinhpr.
      exists (0%NRat,0%NRat) ; repeat split.
      * simpl ; now rewrite islabsorb_zero_multNonnegativeRationals.
      * apply hinhpr.
        exists (/ 2)%NRat ; split.
        simpl fst ; intros.
        rewrite islabsorb_zero_multNonnegativeRationals.
        now apply isnonnegative_NonnegativeRationals.
        split.
        apply (pr1 (ispositive_invNonnegativeRationals _)).
        exact ispositive_twoNonnegativeRationals.
        apply_pr2 (multNonnegativeRationals_ltcompat_l 2%NRat).
        exact ispositive_twoNonnegativeRationals.
        rewrite isrunit_oneNonnegativeRationals, isrinv_NonnegativeRationals.
        exact one_lt_twoNonnegativeRationals.
        exact ispositive_twoNonnegativeRationals.
      * exact Hx0.
    + generalize (is_Dcuts_open _ _ Hx0).
      apply hinhuniv ; intros r.
      apply between_ltNonnegativeRationals in Hq.
      rename Hq into t.
      set (c := pr1 r * (/ pr1 t - 1)%NRat).
      assert (Hc0 : (0 < c)%NRat).
      { unfold c.
        apply ispositive_multNonnegativeRationals.
        exact (pr2 (pr2 r)).
        apply ispositive_minusNonnegativeRationals.
        apply_pr2 (multNonnegativeRationals_ltcompat_l (pr1 t)).
        apply istrans_ltNonnegativeRationals with q.
        exact Hq0.
        exact (pr1 (pr2 t)).
        rewrite isrunit_oneNonnegativeRationals, isrinv_NonnegativeRationals.
        exact (pr2 (pr2 t)).
        apply istrans_ltNonnegativeRationals with q.
        exact Hq0.
        exact (pr1 (pr2 t)). }
      generalize (Dcuts_def_error_not_empty _ Hx0 (is_Dcuts_error x) _ Hc0).
      apply hinhfun ; intros r'.
      exists ((q * / (NQmax (pr1 r) (pr1 r')))%NRat,NQmax (pr1 r) (pr1 r')) ; repeat split.
      * simpl.
        rewrite isassoc_multNonnegativeRationals, islinv_NonnegativeRationals, isrunit_oneNonnegativeRationals.
        reflexivity.
        apply istrans_lt_le_ltNonnegativeRationals with (pr1 r).
        exact (pr2 (pr2 r)).
        now apply NQmax_le_l.
      * apply hinhpr ; simpl fst.
        exists (q / NQmax (pr1 r) (pr1 r') * (NQmax (pr1 r) (pr1 r') + c))%NRat.
        repeat split.
        intros rx Xrx.
        apply multNonnegativeRationals_lecompat_l, lt_leNonnegativeRationals.
        apply (Dcuts_finite x).
        intro H ; apply (pr2 (pr2 r')).
        apply is_Dcuts_bot with (1 := H).
        now apply plusNonnegativeRationals_lecompat_r ; apply NQmax_le_r.
        exact Xrx.
        apply ispositive_multNonnegativeRationals.
        apply ispositive_divNonnegativeRationals.
        exact Hq0.
        apply istrans_lt_le_ltNonnegativeRationals with (pr1 r).
        exact (pr2 (pr2 r)).
        now apply NQmax_le_l.
        rewrite iscomm_plusNonnegativeRationals.
        now apply ispositive_plusNonnegativeRationals_l.
        unfold divNonnegativeRationals.
        apply_pr2 (multNonnegativeRationals_ltcompat_l (/ q)%NRat).
        now apply ispositive_invNonnegativeRationals.
        rewrite isrunit_oneNonnegativeRationals, <- !isassoc_multNonnegativeRationals, islinv_NonnegativeRationals, islunit_oneNonnegativeRationals.
        2: exact Hq0.
        apply_pr2 (multNonnegativeRationals_ltcompat_l (NQmax (pr1 r) (pr1 r'))).
        apply istrans_lt_le_ltNonnegativeRationals with (pr1 r).
        exact (pr2 (pr2 r)).
        now apply NQmax_le_l.
        rewrite <- !isassoc_multNonnegativeRationals, isrinv_NonnegativeRationals, islunit_oneNonnegativeRationals.
        2: apply istrans_lt_le_ltNonnegativeRationals with (pr1 r).
        2: exact (pr2 (pr2 r)).
        2: now apply NQmax_le_l.
        apply (minusNonnegativeRationals_ltcompat_l' _ _ (NQmax (pr1 r) (pr1 r') * 1)%NRat).
        rewrite <- isldistr_mult_minusNonnegativeRationals, isrunit_oneNonnegativeRationals, plusNonnegativeRationals_minus_l.
        unfold c.
        apply multNonnegativeRationals_le_lt.
        exact (pr2 (pr2 r)).
        now apply NQmax_le_l.
        apply_pr2 (multNonnegativeRationals_ltcompat_l q).
        exact Hq0.
        rewrite !isldistr_mult_minusNonnegativeRationals, isrinv_NonnegativeRationals, isrunit_oneNonnegativeRationals.
        2: exact Hq0.
        apply_pr2 (multNonnegativeRationals_ltcompat_r (pr1 t)).
        apply istrans_ltNonnegativeRationals with q.
        exact Hq0.
        exact (pr1 (pr2 t)).
        rewrite !isrdistr_mult_minusNonnegativeRationals, isassoc_multNonnegativeRationals, islinv_NonnegativeRationals, isrunit_oneNonnegativeRationals, islunit_oneNonnegativeRationals.
        2: apply istrans_ltNonnegativeRationals with q.
        apply minusNonnegativeRationals_ltcompat_l.
        exact (pr1 (pr2 t)).
        pattern t at 1 ;
          rewrite <- (islunit_oneNonnegativeRationals (pr1 t)).
        apply multNonnegativeRationals_ltcompat_r.
        apply istrans_ltNonnegativeRationals with q.
        exact Hq0.
        exact (pr1 (pr2 t)).
        apply istrans_ltNonnegativeRationals with (pr1 t).
        exact (pr1 (pr2 t)).
        exact (pr2 (pr2 t)).
        exact Hq0.
        exact (pr1 (pr2 t)).
      * simpl.
        apply NQmax_case.
        exact (pr1 (pr2 r)).
        exact (pr1 (pr2 r')).
Qed.
Lemma isrinv_Dcuts_inv :
  Π x : Dcuts, Π Hx0 : x ≠ 0, Dcuts_mult x (Dcuts_inv x Hx0) = 1.
Proof.
  intros x Hx0.
  rewrite iscomm_Dcuts_mult.
  now apply islinv_Dcuts_inv.
Qed.

Lemma Dcuts_plus_ltcompat_l :
  Π x y z: Dcuts, (y < z) <-> (Dcuts_plus y x < Dcuts_plus z x).
Proof.
  intros x y z.
  split.
  - apply hinhuniv ; intros r.
    generalize (is_Dcuts_open _ _ (pr2 (pr2 r))) ; apply hinhuniv ; intros r'.
    generalize (pr1 r') (pr1 (pr2 r')) (pr2 (pr2 r')) ; clear r' ; intros r' Zr' Hr.
    apply ispositive_minusNonnegativeRationals in Hr.
    generalize (is_Dcuts_error x _ Hr).
    apply hinhuniv ; apply sumofmaps ; [intros nXc | ].
    + apply hinhpr ; exists r' ; split.
      * unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps ; [apply sumofmaps ; [intros Yr' | intros Xr'] | intros yx ].
        apply (pr1 (pr2 r)), is_Dcuts_bot with (1 := Yr'), lt_leNonnegativeRationals.
        now apply_pr2 ispositive_minusNonnegativeRationals.
        apply nXc, is_Dcuts_bot with (1 := Xr'), minusNonnegativeRationals_le.
        generalize (pr1 (pr2 yx)) ; apply gtNonnegativeRationals_noteq.
        pattern r' at 1 ; rewrite <- (minusNonnegativeRationals_plus_r (pr1 r) r'), iscomm_plusNonnegativeRationals.
        apply plusNonnegativeRationals_ltcompat.
        apply (Dcuts_finite y).
        exact (pr1 (pr2 r)).
        exact (pr1 (pr2 (pr2 yx))).
        apply (Dcuts_finite x).
        exact nXc.
        exact (pr2 (pr2 (pr2 yx))).
        apply lt_leNonnegativeRationals.
        now apply_pr2 ispositive_minusNonnegativeRationals.
      * now apply hinhpr ; left ; left.
    + intros q.
      generalize (pr1 q) (pr1 (pr2 q)) (pr2 (pr2 q)) ;
        clear q ;
        intros q Xq nXq.
      apply hinhpr.
      exists (r' + q)%NRat ; split.
      * unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps ; [ apply sumofmaps ; [ intros Yr' | intros Xr'] | intros yx ].
        apply (pr1 (pr2 r)), is_Dcuts_bot with (1 := Yr'), lt_leNonnegativeRationals.
        rewrite <- (isrunit_zeroNonnegativeRationals (pr1 r)).
        apply plusNonnegativeRationals_lt_le_ltcompat.
        now apply_pr2 ispositive_minusNonnegativeRationals.
        now apply isnonnegative_NonnegativeRationals.
        apply nXq, is_Dcuts_bot with (1 := Xr').
        rewrite iscomm_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_r.
        now apply minusNonnegativeRationals_le.
        generalize (pr1 (pr2 yx)) ; apply gtNonnegativeRationals_noteq.
        pattern (r' + q) at 1 ;
          rewrite (iscomm_plusNonnegativeRationals r' q).
        pattern r' at 1 ;
          rewrite <- (minusNonnegativeRationals_plus_r (pr1 r) r'), <- isassoc_plusNonnegativeRationals, iscomm_plusNonnegativeRationals.
        apply plusNonnegativeRationals_ltcompat.
        apply (Dcuts_finite y).
        exact (pr1 (pr2 r)).
        exact (pr1 (pr2 (pr2 yx))).
        apply (Dcuts_finite x).
        exact nXq.
        exact (pr2 (pr2 (pr2 yx))).
        apply lt_leNonnegativeRationals.
        now apply_pr2 ispositive_minusNonnegativeRationals.
      * apply hinhpr ; right ; exists (r',,q) ; repeat split.
        exact Zr'.
        exact Xq.
  - now apply Dcuts_plus_lt_l.
Qed.
Lemma Dcuts_plus_lecompat_l :
  Π x y z: Dcuts, (y <= z) <-> (Dcuts_plus y x <= Dcuts_plus z x).
Proof.
  intros x y z.
  split.
  - intros H ; apply Dcuts_nlt_ge ; intro H0 ; apply (pr2 (Dcuts_nlt_ge _ _) H).
    now apply_pr2 (Dcuts_plus_ltcompat_l x).
  - intros H ; apply Dcuts_nlt_ge ; intro H0 ; apply (pr2 (Dcuts_nlt_ge _ _) H).
    now apply Dcuts_plus_ltcompat_l.
Qed.
Lemma Dcuts_plus_ltcompat_r :
  Π x y z: Dcuts, (y < z) <-> (Dcuts_plus x y < Dcuts_plus x z).
Proof.
  intros x y z.
  rewrite ! (iscomm_Dcuts_plus x).
  now apply Dcuts_plus_ltcompat_l.
Qed.
Lemma Dcuts_plus_lecompat_r :
  Π x y z: Dcuts, (y <= z) <-> (Dcuts_plus x y <= Dcuts_plus x z).
Proof.
  intros x y z.
  rewrite ! (iscomm_Dcuts_plus x).
  now apply Dcuts_plus_lecompat_l.
Qed.

Lemma Dcuts_plus_le_l :
  Π x y, x <= Dcuts_plus x y.
Proof.
  intros x y r Xr.
  now apply hinhpr ; left ; left.
Qed.
Lemma Dcuts_plus_le_r :
  Π x y, y <= Dcuts_plus x y.
Proof.
  intros x y r Xr.
  now apply hinhpr ; left ; right.
Qed.

Lemma Dcuts_mult_ltcompat_l :
  Π x y z: Dcuts, (0 < x) -> (y < z) -> (Dcuts_mult y x < Dcuts_mult z x).
Proof.
  intros X Y Z.
  apply hinhuniv2 ; intros x r.
  generalize (is_Dcuts_bot _ _ (pr2 (pr2 x)) _ (isnonnegative_NonnegativeRationals _)) ; clear x ; intro X0.
  case (eq0orgt0NonnegativeRationals (pr1 r)) ; intro Hr0.
  - apply hinhpr ; exists 0%NRat ; split.
    + unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; intros yx.
      apply (pr1 (pr2 r)).
      rewrite Hr0.
      apply is_Dcuts_bot with (1 := pr1 (pr2 (pr2 yx))).
      now apply isnonnegative_NonnegativeRationals.
    + apply hinhpr ; exists (pr1 r,0%NRat) ; simpl ; repeat split.
      now rewrite israbsorb_zero_multNonnegativeRationals.
      exact (pr2 (pr2 r)).
      exact X0.
  - generalize (is_Dcuts_open _ _ X0) ; apply hinhuniv ; intros x.
    generalize (is_Dcuts_open _ _ (pr2 (pr2 r))) ; apply hinhuniv ; intros r'.
    set (c := ((pr1 r' - pr1 r) / pr1 r * pr1 x)%NRat).
    assert (Hc0 : (0 < c)%NRat).
    { unfold c.
      apply ispositive_multNonnegativeRationals.
      apply ispositive_divNonnegativeRationals.
      apply ispositive_minusNonnegativeRationals.
      exact (pr2 (pr2 r')).
      exact Hr0.
      exact (pr2 (pr2 x)). }
    generalize (Dcuts_def_error_not_empty _ X0 (is_Dcuts_error _) _ Hc0) ; apply hinhfun ; intros x'.
    exists (pr1 r * (NQmax (pr1 x) (pr1 x') + c))%NRat ; split.
    + unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; intros yx.
      generalize (pr1 (pr2 yx)) ; apply gtNonnegativeRationals_noteq.
      apply multNonnegativeRationals_ltcompat.
      apply (Dcuts_finite Y).
      exact (pr1 (pr2 r)).
      exact (pr1 (pr2 (pr2 yx))).
      apply (Dcuts_finite X).
      intro ; apply (pr2 (pr2 x')).
      apply is_Dcuts_bot with (1 := X1).
      apply plusNonnegativeRationals_lecompat_r.
      now apply NQmax_le_r.
      exact (pr2 (pr2 (pr2 yx))).
    + apply hinhpr ; exists (pr1 r',((pr1 r * (NQmax (pr1 x) (pr1 x') + c)) / (pr1 r'))%NRat) ; simpl ; repeat split.
      * rewrite multdivNonnegativeRationals.
        reflexivity.
        apply istrans_le_lt_ltNonnegativeRationals with (pr1 r).
        exact (isnonnegative_NonnegativeRationals _).
        exact (pr2 (pr2 r')).
      * exact (pr1 (pr2 r')).
      * apply (is_Dcuts_bot _ (NQmax (pr1 x) (pr1 x'))%NRat).
        apply NQmax_case.
        exact (pr1 (pr2 x)).
        exact (pr1 (pr2 x')).
        apply multNonnegativeRationals_lecompat_r' with (pr1 r').
        apply istrans_le_lt_ltNonnegativeRationals with (pr1 r).
        exact (isnonnegative_NonnegativeRationals _).
        exact (pr2 (pr2 r')).
        unfold divNonnegativeRationals.
        rewrite !isassoc_multNonnegativeRationals, islinv_NonnegativeRationals, isrunit_oneNonnegativeRationals, isldistr_mult_plusNonnegativeRationals, iscomm_multNonnegativeRationals.
        apply (minusNonnegativeRationals_lecompat_l' (NQmax (pr1 x) (pr1 x') * pr1 r)%NRat).
        apply multNonnegativeRationals_lecompat_l, lt_leNonnegativeRationals.
        exact (pr2 (pr2 r')).
        rewrite plusNonnegativeRationals_minus_l.
        rewrite <- isldistr_mult_minusNonnegativeRationals, iscomm_multNonnegativeRationals.
        apply multNonnegativeRationals_lecompat_r' with (/ pr1 r).
        now apply ispositive_invNonnegativeRationals.
        rewrite !isassoc_multNonnegativeRationals, isrinv_NonnegativeRationals, isrunit_oneNonnegativeRationals, iscomm_multNonnegativeRationals.
        apply multNonnegativeRationals_lecompat_l.
        now apply NQmax_le_l.
        exact Hr0.
        apply istrans_ltNonnegativeRationals with (pr1 r).
        exact Hr0.
        exact (pr2 (pr2 r')).
Qed.
Lemma Dcuts_mult_ltcompat_l' :
  Π x y z: Dcuts, (Dcuts_mult y x < Dcuts_mult z x) -> (y < z).
Proof.
  intros x y z.
  now apply Dcuts_mult_lt_l.
Qed.
Lemma Dcuts_mult_lecompat_l :
  Π x y z: Dcuts, (0 < x) -> (Dcuts_mult y x <= Dcuts_mult z x) -> (y <= z).
Proof.
  intros x y z Hx0.
  intros H ; apply Dcuts_nlt_ge ; intro H0 ; apply (pr2 (Dcuts_nlt_ge _ _) H).
  now apply Dcuts_mult_ltcompat_l.
Qed.
Lemma Dcuts_mult_lecompat_l' :
  Π x y z: Dcuts, (y <= z) -> (Dcuts_mult y x <= Dcuts_mult z x).
Proof.
  intros x y z.
  intros H ; apply Dcuts_nlt_ge ; intro H0 ; apply (pr2 (Dcuts_nlt_ge _ _) H).
  now apply (Dcuts_mult_ltcompat_l' x).
Qed.

Lemma Dcuts_mult_ltcompat_r :
  Π x y z: Dcuts, (0 < x) -> (y < z) -> (Dcuts_mult x y < Dcuts_mult x z).
Proof.
  intros x y z.
  rewrite ! (iscomm_Dcuts_mult x).
  now apply Dcuts_mult_ltcompat_l.
Qed.
Lemma Dcuts_mult_ltcompat_r' :
  Π x y z: Dcuts, (Dcuts_mult x y < Dcuts_mult x z) -> (y < z).
Proof.
  intros x y z.
  rewrite ! (iscomm_Dcuts_mult x).
  now apply Dcuts_mult_ltcompat_l'.
Qed.
Lemma Dcuts_mult_lecompat_r :
  Π x y z: Dcuts, (0 < x) -> (Dcuts_mult x y <= Dcuts_mult x z) -> (y <= z).
Proof.
  intros x y z.
  rewrite ! (iscomm_Dcuts_mult x).
  now apply Dcuts_mult_lecompat_l.
Qed.
Lemma Dcuts_mult_lecompat_r' :
  Π x y z: Dcuts, (y <= z) -> (Dcuts_mult x y <= Dcuts_mult x z).
Proof.
  intros x y z.
  rewrite ! (iscomm_Dcuts_mult x).
  now apply Dcuts_mult_lecompat_l'.
Qed.

Lemma Dcuts_plus_double :
  Π x : Dcuts, Dcuts_plus x x = Dcuts_mult Dcuts_two x.
Proof.
  intros x.
  rewrite <- (Dcuts_NQmult_mult _ _ ispositive_twoNonnegativeRationals).
  apply Dcuts_eq_is_eq.
  intros r ; split.
  - apply hinhfun ; apply sumofmaps ; [ apply sumofmaps ; intros Xr | intros xy ; rewrite (pr1 (pr2 xy))].
    + exists (r / 2)%NRat.
      simpl ; split.
      * apply pathsinv0, multdivNonnegativeRationals.
        exact ispositive_twoNonnegativeRationals.
      * apply is_Dcuts_bot with (1 := Xr).
        pattern r at 2 ; rewrite (NQhalf_double r).
        apply plusNonnegativeRationals_le_l.
    + exists (r / 2)%NRat.
      simpl ; split.
      * apply pathsinv0, multdivNonnegativeRationals.
        exact ispositive_twoNonnegativeRationals.
      * apply is_Dcuts_bot with (1 := Xr).
        pattern r at 2 ; rewrite (NQhalf_double r).
        apply plusNonnegativeRationals_le_l.
    + exists ((pr1 (pr1 xy) + pr2 (pr1 xy)) / 2)%NRat.
      split.
      * apply pathsinv0, multdivNonnegativeRationals.
        exact ispositive_twoNonnegativeRationals.
      * generalize (isdecrel_ltNonnegativeRationals (pr1 (pr1 xy)) (pr2 (pr1 xy))) ; apply sumofmaps ; intros H.
        apply is_Dcuts_bot with (1 := pr2 (pr2 (pr2 xy))).
        pattern (pr2 (pr1 xy)) at 2 ; rewrite (NQhalf_double (pr2 (pr1 xy))).
        unfold divNonnegativeRationals.
        rewrite isrdistr_mult_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_r.
        apply multNonnegativeRationals_lecompat_r.
        now apply lt_leNonnegativeRationals.
        apply is_Dcuts_bot with (1 := pr1 (pr2 (pr2 xy))).
        pattern (pr1 (pr1 xy)) at 2 ; rewrite (NQhalf_double (pr1 (pr1 xy))).
        unfold divNonnegativeRationals.
        rewrite isrdistr_mult_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_l.
        apply multNonnegativeRationals_lecompat_r.
        now apply notlt_geNonnegativeRationals.
  - apply hinhfun ; intros q ; rewrite (pr1 (pr2 q)).
    right.
    exists (pr1 q,,pr1 q).
    repeat split.
    + assert (2 = 1+1)%NRat.
      { apply subtypeEquality_prop ; simpl.
        apply hq2eq1plus1. }
      pattern 2%NRat at 1 ; rewrite X ; clear X.
      rewrite isrdistr_mult_plusNonnegativeRationals, islunit_oneNonnegativeRationals.
      reflexivity.
    + exact (pr2 (pr2 q)).
    + exact (pr2 (pr2 q)).
Qed.

(** ** Structures *)

Definition Dcuts_setwith2binop : setwith2binop.
Proof.
  exists Dcuts.
  split.
  - exact Dcuts_plus.
  - exact Dcuts_mult.
Defined.

Definition isabmonoidop_Dcuts_plus : isabmonoidop Dcuts_plus.
Proof.
  repeat split.
  - exact isassoc_Dcuts_plus.
  - exists Dcuts_zero.
    split.
    + exact islunit_Dcuts_plus_zero.
    + exact isrunit_Dcuts_plus_zero.
  - exact iscomm_Dcuts_plus.
Defined.

Definition ismonoidop_Dcuts_mult : ismonoidop Dcuts_mult.
Proof.
  split.
  - exact isassoc_Dcuts_mult.
  - exists Dcuts_one.
    split.
    + exact islunit_Dcuts_mult_one.
    + exact isrunit_Dcuts_mult_one.
Defined.

Definition Dcuts_commrig : commrig.
Proof.
  exists Dcuts_setwith2binop.
  repeat split.
  - exists (isabmonoidop_Dcuts_plus,,ismonoidop_Dcuts_mult).
    split.
    + exact islabsorb_Dcuts_mult_zero.
    + exact israbsorb_Dcuts_mult_zero.
  - exact isldistr_Dcuts_plus_mult.
  - exact isrdistr_Dcuts_plus_mult.
  - exact iscomm_Dcuts_mult.
Defined.

Definition Dcuts_ConstructiveCommutativeDivisionRig : ConstructiveCommutativeDivisionRig.
Proof.
  exists Dcuts_commrig.
  exists (pr2 Dcuts).
  repeat split.
  - exact islapbinop_Dcuts_plus.
  - exact israpbinop_Dcuts_plus.
  - exact islapbinop_Dcuts_mult.
  - exact israpbinop_Dcuts_mult.
  - exact Dcuts_ap_one_zero.
  - intros x Hx.
    exists (Dcuts_inv x Hx) ; split.
    + exact (islinv_Dcuts_inv x Hx).
    + exact (isrinv_Dcuts_inv x Hx).
Defined.

(** ** Additional usefull definitions *)
(** *** Dcuts_minus *)

Section Dcuts_minus.

  Context (X : hsubtypes NonnegativeRationals).
  Context (X_bot : Dcuts_def_bot X).
  Context (X_open : Dcuts_def_open X).
  Context (X_error : Dcuts_def_error X).
  Context (Y : hsubtypes NonnegativeRationals).
  Context (Y_bot : Dcuts_def_bot Y).
  Context (Y_open : Dcuts_def_open Y).
  Context (Y_error : Dcuts_def_error Y).

Definition Dcuts_minus_val : hsubtypes NonnegativeRationals :=
  fun r => ∃ x, X x × Π y, (Y y) ⨿ (y = 0%NRat) -> (r + y < x)%NRat.

Lemma Dcuts_minus_bot : Dcuts_def_bot Dcuts_minus_val.
Proof.
  intros r Hr q Hle.
  revert Hr ; apply hinhfun ; intros x.
  exists (pr1 x) ; split.
  - exact (pr1 (pr2 x)).
  - intros y Yy.
    apply istrans_le_lt_ltNonnegativeRationals with (r + y).
    apply plusNonnegativeRationals_lecompat_r.
    exact Hle.
    now apply (pr2 (pr2 x)).
Qed.

Lemma Dcuts_minus_open : Dcuts_def_open Dcuts_minus_val.
Proof.
  intros r.
  apply hinhuniv ; intros x.
  generalize (X_open _ (pr1 (pr2 x))).
  apply hinhfun ; intros x'.
  exists (r + (pr1 x' - pr1 x)) ; split.
  - apply hinhpr ; exists (pr1 x') ; split.
    + exact (pr1 (pr2 x')).
    + intros y Yy.
      pattern (pr1 x') at 2 ;
        rewrite <- (minusNonnegativeRationals_plus_r _ _ (lt_leNonnegativeRationals _ _ (pr2 (pr2 x')))).
      rewrite (iscomm_plusNonnegativeRationals r), isassoc_plusNonnegativeRationals.
      apply plusNonnegativeRationals_ltcompat_l.
      now apply (pr2 (pr2 x)).
  - apply plusNonnegativeRationals_lt_r.
    apply ispositive_minusNonnegativeRationals.
    exact (pr2 (pr2 x')).
Qed.

Lemma Dcuts_minus_error : Dcuts_def_error Dcuts_minus_val.
Proof.
  assert (Y_error' : Dcuts_def_error (λ y, Y y ∨ (y = 0%NRat))).
  { intros c Hc.
    generalize (Y_error c Hc) ; apply hinhfun ; apply sumofmaps ; [intros Yc | intros y ].
    - left.
      intros H ; apply Yc ; clear Yc ; revert H.
      apply hinhuniv ; apply sumofmaps ; [intros Yc | intros Hc0].
      + exact Yc.
      + rewrite Hc0 in Hc.
        now apply fromempty, (isirrefl_ltNonnegativeRationals 0%NRat).
    - right.
      exists (pr1 y) ; split.
      + apply hinhpr ; left.
        exact (pr1 (pr2 y)).
      + intros H ; apply (pr2 (pr2 y)) ; revert H.
        apply hinhuniv ; apply sumofmaps ; [intros H | intros Hc0].
        * exact H.
        * apply fromempty ; revert Hc0.
          apply gtNonnegativeRationals_noteq.
          now apply ispositive_plusNonnegativeRationals_r. }
  intros c Hc.
  apply ispositive_NQhalf in Hc.
  apply (fun X X0 Xerr => Dcuts_def_error_not_empty X X0 Xerr _ Hc) in Y_error'.
  revert Y_error' ; apply hinhuniv ; intros y.
  generalize (pr1 (pr2 y)) ; apply hinhuniv ; intros Yy.
  assert (¬ Y (pr1 y + c / 2%NRat)).
  { intro ; apply (pr2 (pr2 y)).
    now apply hinhpr ; left. }
  rename X0 into nYy.
  generalize (X_error _ Hc) ; apply hinhuniv ; apply sumofmaps ; [intros Xc | intros x].

  - apply hinhpr ; left ; intro H ; apply Xc.
    revert H ; apply hinhuniv ; intros x.
    apply X_bot with (1 := pr1 (pr2 x)).
    apply istrans_leNonnegativeRationals with c.
    pattern c at 2 ; rewrite (NQhalf_double c).
    now apply plusNonnegativeRationals_le_r.
    apply lt_leNonnegativeRationals.
    pattern c at 1 ;
      rewrite <- (isrunit_zeroNonnegativeRationals c).
    apply (pr2 (pr2 x)).
    now right.
  - generalize (isdecrel_leNonnegativeRationals (pr1 y + c / 2)%NRat (pr1 x)) ; apply sumofmaps ; intro Hxy.
    + assert (HY : Π y', coprod (Y y') (y' = 0%NRat) -> (y' < pr1 y + c / 2)%NRat).
      { intros y' ; apply sumofmaps ; intros Yy'.
        apply notge_ltNonnegativeRationals ; intro H ; apply nYy.
        now apply Y_bot with (1 := Yy').
        rewrite Yy'.
        now apply ispositive_plusNonnegativeRationals_r. }
      apply hinhpr ; right ; exists (pr1 x - (pr1 y + c / 2))%NRat ; split.
      * apply hinhpr.
        exists (pr1 x) ; split.
        exact (pr1 (pr2 x)).
        intros y' Yy'.
        pattern (pr1 x) at 2 ;
        rewrite <- (minusNonnegativeRationals_plus_r _ _ Hxy).
        apply plusNonnegativeRationals_ltcompat_l.
        now apply HY.
      * unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; intros (x',(Xx',Hx')).
        specialize (Hx' (pr1 y) Yy).
        revert Hx'.
        apply_pr2 notlt_geNonnegativeRationals.
        apply istrans_leNonnegativeRationals with (pr1 x + c / 2)%NRat.
        apply lt_leNonnegativeRationals.
        apply notge_ltNonnegativeRationals ; intro H ; apply (pr2 (pr2 x)).
        now apply X_bot with (1 := Xx').
        rewrite isassoc_plusNonnegativeRationals, (iscomm_plusNonnegativeRationals _ (pr1 y)).
        pattern c at 9 ; rewrite (NQhalf_double c).
        rewrite <- (isassoc_plusNonnegativeRationals (pr1 y)), <- isassoc_plusNonnegativeRationals.
        rewrite minusNonnegativeRationals_plus_r.
        apply isrefl_leNonnegativeRationals.
        exact Hxy.
    + apply notge_ltNonnegativeRationals in Hxy.
      apply hinhpr ; left ; unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; intros (x',(Xx',Hx')).
      generalize (Hx' _ Yy).
      apply_pr2 notlt_geNonnegativeRationals.
      case (isdecrel_leNonnegativeRationals (pr1 y) x') ; intro Hxy'.
      rewrite iscomm_plusNonnegativeRationals.
      pattern c at 3 ; rewrite (NQhalf_double c), <- isassoc_plusNonnegativeRationals.
      apply istrans_leNonnegativeRationals with (pr1 x + c / 2)%NRat.
      apply lt_leNonnegativeRationals ; apply notge_ltNonnegativeRationals ; intro ; apply (pr2 (pr2 x)).
      now apply X_bot with (1 := Xx').
      apply plusNonnegativeRationals_lecompat_r.
      now apply lt_leNonnegativeRationals.
      apply notge_ltNonnegativeRationals in Hxy'.
      apply istrans_leNonnegativeRationals with (pr1 y).
      now apply lt_leNonnegativeRationals.
      now apply plusNonnegativeRationals_le_l.
  - now apply hinhpr ; right.
Qed.

End Dcuts_minus.

Definition Dcuts_minus (X Y : Dcuts) : Dcuts :=
  mk_Dcuts (Dcuts_minus_val (pr1 X) (pr1 Y))
           (Dcuts_minus_bot (pr1 X) (pr1 Y))
           (Dcuts_minus_open (pr1 X) (is_Dcuts_open X) (pr1 Y))
           (Dcuts_minus_error (pr1 X) (is_Dcuts_bot X) (is_Dcuts_error X)
                              (pr1 Y) (is_Dcuts_bot Y) (is_Dcuts_error Y)).

Lemma Dcuts_minus_correct_l:
  Π x y z : Dcuts, x = Dcuts_plus y z -> z = Dcuts_minus x y.
Proof.
  intros _ Y Z ->.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - intros Zr.
    generalize (is_Dcuts_open _ _ Zr) ; apply hinhuniv ; intros (q,(Zq,Hq)).
    apply ispositive_minusNonnegativeRationals in Hq.
    generalize (is_Dcuts_error Y _ Hq) ; apply hinhuniv ; intros [nYy | ].
    + apply hinhpr ; exists q ; split.
      * now apply hinhpr ; left ; right.
      * intros y [Yy | Hy0].
        apply minusNonnegativeRationals_ltcompat_l' with r.
        rewrite plusNonnegativeRationals_minus_l.
        now apply (Dcuts_finite Y).
        rewrite Hy0, isrunit_zeroNonnegativeRationals.
        now apply_pr2 ispositive_minusNonnegativeRationals.
    + intros y.
      apply hinhpr.
      exists (pr1 y + q) ; split.
      apply hinhpr ; right ; exists (pr1 y,,q) ; simpl ; repeat split.
      * exact (pr1 (pr2 y)).
      * exact Zq.
      * intros y' [Yy' | Hy0].
        apply minusNonnegativeRationals_ltcompat_l' with r.
        rewrite plusNonnegativeRationals_minus_l.
        rewrite iscomm_plusNonnegativeRationals, <- minusNonnegativeRationals_plus_exchange, iscomm_plusNonnegativeRationals.
        apply (Dcuts_finite Y).
        exact (pr2 (pr2 y)).
        exact Yy'.
        now apply lt_leNonnegativeRationals ; apply_pr2 ispositive_minusNonnegativeRationals.
        rewrite Hy0, isrunit_zeroNonnegativeRationals.
        apply istrans_lt_le_ltNonnegativeRationals with q.
        now apply_pr2 ispositive_minusNonnegativeRationals.
        now apply plusNonnegativeRationals_le_l.
  - apply hinhuniv ; intros q.
    generalize (pr1 (pr2 q)) ; apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; [intros Yq | intros Zq ] | intros yz ].
    + apply fromempty, (isnonnegative_NonnegativeRationals' r).
      apply_pr2 (plusNonnegativeRationals_ltcompat_r (pr1 q)).
      rewrite islunit_zeroNonnegativeRationals.
      apply (pr2 (pr2 q)).
      now left.
    + apply is_Dcuts_bot with (1 := Zq), lt_leNonnegativeRationals.
      pattern r at 1 ;
        rewrite <- (isrunit_zeroNonnegativeRationals r).
      apply (pr2 (pr2 q)).
      now right.
    + apply is_Dcuts_bot with (1 := pr2 (pr2 (pr2 yz))), lt_leNonnegativeRationals.
      apply_pr2 (plusNonnegativeRationals_ltcompat_l (pr1 (pr1 yz))).
      rewrite <- (pr1 (pr2 yz)), iscomm_plusNonnegativeRationals.
      apply (pr2 (pr2 q)).
      left.
      exact (pr1 (pr2 (pr2 yz))).
Qed.
Lemma Dcuts_minus_correct_r:
  Π x y z : Dcuts, x = Dcuts_plus y z -> y = Dcuts_minus x z.
Proof.
  intros x y z Hx.
  apply Dcuts_minus_correct_l.
  rewrite Hx.
  now apply iscomm_Dcuts_plus.
Qed.
Lemma Dcuts_minus_eq_zero:
  Π x y : Dcuts, x <= y -> Dcuts_minus x y = 0.
Proof.
  intros X Y Hxy.
  apply Dcuts_eq_is_eq ; intros r ; split.
  - apply hinhuniv ; intros (x,(Xx,Hx)).
    apply_pr2 (plusNonnegativeRationals_ltcompat_r x).
    rewrite islunit_zeroNonnegativeRationals.
    apply Hx.
    now left ; apply Hxy.
  - intro H.
    now apply fromempty ; apply (Dcuts_zero_empty r).
Qed.
Lemma Dcuts_minus_plus_r:
  Π x y z : Dcuts, z <= y -> x = Dcuts_minus y z -> y = Dcuts_plus x z.
Proof.
  intros _ Y Z Hyz ->.
  apply Dcuts_eq_is_eq ; intro r ; split.
  - intros Yr.
    generalize (is_Dcuts_open _ _ Yr) ; apply hinhuniv ; intros q.
    generalize (pr1 (ispositive_minusNonnegativeRationals _ _) (pr2 (pr2 q))) ; intros Hq.
    generalize (is_Dcuts_error Z _ Hq).
    apply hinhuniv ; apply sumofmaps ; [intros nZ | ].
    + apply hinhpr ; left ; left.
      apply hinhpr.
      exists (pr1 q) ; split.
      exact (pr1 (pr2 q)).
      intros z [Zz | ->].
      * apply (minusNonnegativeRationals_ltcompat_l' _ _ r).
        rewrite plusNonnegativeRationals_minus_l.
        now apply (Dcuts_finite Z).
      * now rewrite isrunit_zeroNonnegativeRationals ;
        apply_pr2 ispositive_minusNonnegativeRationals.
    + intros (z,(Zz,nZz)).
      case (isdecrel_leNonnegativeRationals r z) ; intro Hzr.
      * apply hinhpr ; left ; right.
        now apply (is_Dcuts_bot _ _ Zz).
      * apply notge_ltNonnegativeRationals in Hzr ; apply lt_leNonnegativeRationals in Hzr.
        apply hinhpr ; right.
        exists (r - z ,, z) ; repeat split.
        simpl.
        now rewrite minusNonnegativeRationals_plus_r.
        apply hinhpr ; simpl.
        exists (pr1 q) ; split.
        exact (pr1 (pr2 q)).
        intros z' [Zz' | ->].
        apply_pr2 (plusNonnegativeRationals_ltcompat_r z).
        rewrite isassoc_plusNonnegativeRationals, (iscomm_plusNonnegativeRationals z'), <- isassoc_plusNonnegativeRationals.
        rewrite minusNonnegativeRationals_plus_r.
        apply (minusNonnegativeRationals_ltcompat_l' _ _ r) ; rewrite plusNonnegativeRationals_minus_l.
        rewrite <- minusNonnegativeRationals_plus_exchange, iscomm_plusNonnegativeRationals.
        apply (Dcuts_finite Z).
        exact nZz.
        exact Zz'.
        now apply lt_leNonnegativeRationals ; apply_pr2 ispositive_minusNonnegativeRationals.
        now apply Hzr.
        rewrite isrunit_zeroNonnegativeRationals.
        apply istrans_le_lt_ltNonnegativeRationals with r.
        now apply minusNonnegativeRationals_le.
        now apply_pr2 ispositive_minusNonnegativeRationals.
        exact Zz.
  - apply hinhuniv ; intros [ | ] ; [intros [ YZr | Zr] | intros ((ryz,rz),(->,(YZr,Zr))) ].
    + revert YZr ; apply hinhuniv ; intros (y,(Yy,Hy)).
      apply (is_Dcuts_bot _ _ Yy).
      apply lt_leNonnegativeRationals ; rewrite <- (isrunit_zeroNonnegativeRationals r).
      apply Hy.
      now right.
    + now apply Hyz.
    + simpl in Zr |- *.
      revert YZr ; apply hinhuniv ; simpl ; intros (y,(Yy,Hy)).
      apply (is_Dcuts_bot _ _ Yy).
      apply lt_leNonnegativeRationals, Hy.
      now left.
Qed.

Lemma Dcuts_minus_le :
  Π x y, Dcuts_minus x y <= x.
Proof.
  intros X Y r.
  apply hinhuniv ; intros (x,(Xx,Hx)).
  apply is_Dcuts_bot with (1 := Xx).
  apply lt_leNonnegativeRationals ; rewrite <- (isrunit_zeroNonnegativeRationals r).
  apply Hx.
  now right.
Qed.

Lemma ispositive_Dcuts_minus :
  Π x y : Dcuts, (y < x) <-> (0 < Dcuts_minus x y).
Proof.
  intros X Y.
  split.
  - apply hinhuniv ; intros x.
    generalize (is_Dcuts_open _ _ (pr2 (pr2 x))) ; apply hinhfun ; intros x'.
    exists 0%NRat ; split.
    + now apply (isnonnegative_NonnegativeRationals' 0%NRat).
    + apply hinhpr.
      exists (pr1 x') ; split.
      exact (pr1 (pr2 x')).
      intros y [Yy | ->].
      * rewrite islunit_zeroNonnegativeRationals.
        apply istrans_ltNonnegativeRationals with (pr1 x).
        apply (Dcuts_finite Y).
        exact (pr1 (pr2 x)).
        exact Yy.
        exact (pr2 (pr2 x')).
      * rewrite islunit_zeroNonnegativeRationals.
        apply istrans_le_lt_ltNonnegativeRationals with (pr1 x).
        now apply isnonnegative_NonnegativeRationals.
        exact (pr2 (pr2 x')).
  - apply hinhuniv ; intros (r,(_)).
    apply hinhfun ; intros (x,(Xx,Hx)).
    exists x ; split.
    + intros Yx ; apply (isnonnegative_NonnegativeRationals' r).
      apply_pr2 (plusNonnegativeRationals_ltcompat_r x).
      rewrite islunit_zeroNonnegativeRationals.
      now apply Hx ; left.
    + exact Xx.
Qed.

(** *** Dcuts_max *)

Section Dcuts_max.

  Context (X : hsubtypes NonnegativeRationals).
  Context (X_bot : Dcuts_def_bot X).
  Context (X_open : Dcuts_def_open X).
  Context (X_finite : Dcuts_def_finite X).
  Context (X_error : Dcuts_def_error X).
  Context (Y : hsubtypes NonnegativeRationals).
  Context (Y_bot : Dcuts_def_bot Y).
  Context (Y_open : Dcuts_def_open Y).
  Context (Y_finite : Dcuts_def_finite Y).
  Context (Y_error : Dcuts_def_error Y).

Definition Dcuts_max_val : hsubtypes NonnegativeRationals :=
  λ r : NonnegativeRationals, X r ∨ Y r.

Lemma Dcuts_max_bot : Dcuts_def_bot Dcuts_max_val.
Proof.
  intros r Hr q Hqr.
  revert Hr ; apply hinhfun ; apply sumofmaps ; [ intros Xr| intros Yr].
  - left ; now apply X_bot with (1 := Xr).
  - right ; now apply Y_bot with (1 := Yr).
Qed.

Lemma Dcuts_max_open : Dcuts_def_open Dcuts_max_val.
Proof.
  intros r ; apply hinhuniv ; apply sumofmaps ; [ intros Xr | intros Yr].
  - generalize (X_open _ Xr).
    apply hinhfun ; intros q.
    exists (pr1 q) ; split.
    apply hinhpr ; left.
    exact (pr1 (pr2 q)).
    exact (pr2 (pr2 q)).
  - generalize (Y_open _ Yr).
    apply hinhfun ; intros q.
    exists (pr1 q) ; split.
    apply hinhpr ; right.
    exact (pr1 (pr2 q)).
    exact (pr2 (pr2 q)).
Qed.

Lemma Dcuts_max_error : Dcuts_def_error Dcuts_max_val.
Proof.
  intros c Hc.
  generalize (X_error _ Hc) (Y_error _ Hc) ; apply hinhfun2 ; apply (sumofmaps (Z := _ → _)) ; [intros nXc | intros x] ; apply sumofmaps ; [intros nYc | intros y|intros nYc | intros y].
  - left ; unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps ; [intros Xc | intros Yc].
    + now apply nXc.
    + now apply nYc.
  - right.
    exists (pr1 y) ; split.
    + apply hinhpr ; right.
      exact (pr1 (pr2 y)).
    + unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps ; [intros Xy | intros Yy].
      * now apply nXc, X_bot with (1 := Xy), plusNonnegativeRationals_le_l.
      * now apply (pr2 (pr2 y)).
  - right.
    exists (pr1 x) ; split.
    + apply hinhpr ; left.
      exact (pr1 (pr2 x)).
    + unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps ; [intros Xx | intros Yx].
      * now apply (pr2 (pr2 x)).
      * now apply nYc, Y_bot with (1 := Yx), plusNonnegativeRationals_le_l.
  - right.
    exists (NQmax (pr1 x) (pr1 y)) ; split.
    + apply NQmax_case.
      * apply hinhpr ; left.
        exact (pr1 (pr2 x)).
      * apply hinhpr ; right.
        exact (pr1 (pr2 y)).
    + unfold neg ; apply (hinhuniv (P := hProppair _ isapropempty)) ; apply sumofmaps ; [ intros Xxy | intros Yxy].
      * apply (pr2 (pr2 x)), X_bot with (1 := Xxy).
        apply plusNonnegativeRationals_lecompat_r.
        now apply NQmax_le_l.
      * apply (pr2 (pr2 y)), Y_bot with (1 := Yxy).
        apply plusNonnegativeRationals_lecompat_r.
        now apply NQmax_le_r.
Qed.

End Dcuts_max.

Definition Dcuts_max (X Y : Dcuts) : Dcuts :=
  mk_Dcuts (Dcuts_max_val (pr1 X) (pr1 Y))
           (Dcuts_max_bot (pr1 X) (is_Dcuts_bot X)
                          (pr1 Y) (is_Dcuts_bot Y))
           (Dcuts_max_open (pr1 X) (is_Dcuts_open X)
                           (pr1 Y) (is_Dcuts_open Y))
           (Dcuts_max_error (pr1 X) (is_Dcuts_bot X) (is_Dcuts_error X)
                            (pr1 Y) (is_Dcuts_bot Y) (is_Dcuts_error Y)).

Lemma iscomm_Dcuts_max :
  Π x y : Dcuts, Dcuts_max x y = Dcuts_max y x.
Proof.
  intros x y.
  apply Dcuts_eq_is_eq ; intros r.
  split ; apply islogeqcommhdisj.
Qed.
Lemma isassoc_Dcuts_max :
  Π x y z : Dcuts, Dcuts_max (Dcuts_max x y) z = Dcuts_max x (Dcuts_max y z).
Proof.
  intros x y z.
  apply Dcuts_eq_is_eq ; intros r.
  split.
  - apply hinhuniv ; intros [ | Zr].
    + apply hinhfun ; intros [Xr | Yr].
      * now left.
      * right ; apply hinhpr.
        now left.
    + apply hinhpr.
      right ; apply hinhpr.
      now right.
  - apply hinhuniv ; intros [ Xr | ].
    + apply hinhpr.
      left ; apply hinhpr.
      now left.
    + apply hinhfun ; intros [Yr | Zr].
      * left ; apply hinhpr.
        now right.
      * now right.
Qed.

Lemma Dcuts_max_le_l :
  Π x y : Dcuts, x <= Dcuts_max x y.
Proof.
  intros x y r Xr.
  apply hinhpr.
  now left.
Qed.
Lemma Dcuts_max_le_r :
  Π x y : Dcuts, y <= Dcuts_max x y.
Proof.
  intros x y r Xr.
  apply hinhpr.
  now right.
Qed.

Lemma Dcuts_max_carac_l :
  Π x y : Dcuts, y <= x -> Dcuts_max x y = x.
Proof.
  intros x y Hxy.
  apply Dcuts_eq_is_eq ; intros r ; split.
  apply hinhuniv ; apply sumofmaps ; [intros Xr|intros Yr].
  - exact Xr.
  - now refine (Hxy _ _).
  - intros Xr.
    now apply hinhpr ; left.
Qed.
Lemma Dcuts_max_carac_r :
  Π x y : Dcuts, x <= y -> Dcuts_max x y = y.
Proof.
  intros x y Hxy.
  rewrite iscomm_Dcuts_max.
  now apply Dcuts_max_carac_l.
Qed.

Lemma Dcuts_minus_plus_max :
  Π x y : Dcuts, Dcuts_plus (Dcuts_minus x y) y = Dcuts_max x y.
Proof.
  intros X Y.
  apply Dcuts_eq_is_eq ; intros r ; split.
  - apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; [intros XYr | intros Yr] | intros xyy ; rewrite (pr1 (pr2 xyy))].
    + apply hinhpr ; left.
      revert XYr ; now refine (Dcuts_minus_le _ _ _).
    + now apply hinhpr ; right.
    + generalize (pr1 (pr2 (pr2 xyy))) ; apply hinhfun ; intros x.
      left ; apply is_Dcuts_bot with (1 := pr1 (pr2 x)).
      apply lt_leNonnegativeRationals.
      apply (pr2 (pr2 x)).
      left.
      exact (pr2 (pr2 (pr2 xyy))).
  - apply hinhuniv ; apply sumofmaps ; [intros Xr|intros Yr].
    + generalize (is_Dcuts_open _ _ Xr) ; apply hinhuniv ; intros x.
      generalize (pr1 (ispositive_minusNonnegativeRationals _ _) (pr2 (pr2 x))) ; intros Hx.
      generalize (is_Dcuts_error Y _ Hx) ; apply hinhuniv ;
      apply sumofmaps ; [ intros nYx | intros Hyx ] ; apply_pr2_in ispositive_minusNonnegativeRationals Hx.
      * rewrite <- (Dcuts_minus_plus_r (Dcuts_minus X Y) X Y).
        exact Xr.
        apply Dcuts_lt_le_rel.
        apply hinhpr ; exists (pr1 x - r) ; split.
        exact nYx.
        apply is_Dcuts_bot with (1 := pr1 (pr2 x)).
        now apply minusNonnegativeRationals_le.
        reflexivity.
      * rename Hyx into y.
        generalize (pr2 (pr2 y)) ; intros nYy.
        rewrite iscomm_plusNonnegativeRationals, minusNonnegativeRationals_plus_exchange in nYy.
        2: now apply lt_leNonnegativeRationals.
        generalize (isdecrel_leNonnegativeRationals r (pr1 y)) ; apply sumofmaps ; intros Hle.
        { apply hinhpr ; left ; right.
          now apply is_Dcuts_bot with (1 := pr1 (pr2 y)). }
        apply notge_ltNonnegativeRationals in Hle.
        rewrite <- (Dcuts_minus_plus_r (Dcuts_minus X Y) X Y).
        exact Xr.
        apply Dcuts_lt_le_rel.
        apply hinhpr ; exists ((pr1 x + pr1 y) - r) ; split.
        exact nYy.
        apply is_Dcuts_bot with (1 := pr1 (pr2 x)).
        pattern (pr1 x) at 3 ;
          rewrite <- (plusNonnegativeRationals_minus_r r (pr1 x)).
        apply minusNonnegativeRationals_lecompat_l.
        apply plusNonnegativeRationals_lecompat_l.
        now apply lt_leNonnegativeRationals.
        reflexivity.
    + now apply hinhpr ; left ; right.
Qed.

Lemma Dcuts_max_le :
  Π x y z, x <= z -> y <= z -> Dcuts_max x y <= z.
Proof.
  intros x y z Hx Hy r.
  apply hinhuniv ; apply sumofmaps ; [intros Xr|intros Yr].
  now refine (Hx _ _).
  now refine (Hy _ _).
Qed.
Lemma Dcuts_max_lt :
  Π x y z : Dcuts, x < z -> y < z -> Dcuts_max x y < z.
Proof.
  intros x y z.
  apply hinhfun2 ; intros rx ry.
  exists (NQmax (pr1 rx) (pr1 ry)) ; split.
  - apply NQmax_case_strong ; intro Hr.
    + intro Hr' ; apply (pr1 (pr2 ry)).
      revert Hr' ; apply hinhuniv ; apply sumofmaps ; [ intros Xr | intros Yr].
      now apply fromempty, (pr1 (pr2 rx)).
      now apply is_Dcuts_bot with (1 := Yr).
    + intro Hr' ; apply (pr1 (pr2 rx)).
      revert Hr' ; apply hinhuniv ; apply sumofmaps ; [intros Xr | intros Yr].
      now apply is_Dcuts_bot with (1 := Xr).
      now apply fromempty, (pr1 (pr2 ry)).
  - apply NQmax_case.
    exact (pr2 (pr2 rx)).
    exact (pr2 (pr2 ry)).
Qed.

Lemma isldistr_Dcuts_max_mult :
  isldistr Dcuts_max Dcuts_mult.
Proof.
  intros x y z.
  apply Dcuts_eq_is_eq.
  intros r ; split.
  - apply hinhuniv.
    intros zxy.
    rewrite (pr1 (pr2 zxy)).
    generalize (pr2 (pr2 (pr2 zxy))).
    apply hinhfun.
    apply sumofmaps ; [intros Xr | intros Yr].
    + left.
      apply hinhpr.
      exists (pr1 zxy).
      repeat split.
      exact (pr1 (pr2 (pr2 zxy))).
      exact Xr.
    + right.
      apply hinhpr.
      exists (pr1 zxy).
      repeat split.
      exact (pr1 (pr2 (pr2 zxy))).
      exact Yr.
  - apply hinhuniv.
    apply sumofmaps.
    + apply hinhfun.
      intros zx.
      rewrite (pr1 (pr2 zx)).
      exists (pr1 zx).
      repeat split.
      exact (pr1 (pr2 (pr2 zx))).
      apply hinhpr.
      left.
      exact (pr2 (pr2 (pr2 zx))).
    + apply hinhfun.
      intros zy.
      rewrite (pr1 (pr2 zy)).
      exists (pr1 zy).
      repeat split.
      exact (pr1 (pr2 (pr2 zy))).
      apply hinhpr.
      right.
      exact (pr2 (pr2 (pr2 zy))).
Qed.
Lemma isrdistr_Dcuts_max_mult :
  isrdistr Dcuts_max Dcuts_mult.
Proof.
  intros x y z.
  rewrite !(iscomm_Dcuts_mult _ z).
  now apply isldistr_Dcuts_max_mult.
Qed.

Lemma isldistr_Dcuts_max_plus :
  isldistr Dcuts_max Dcuts_plus.
Proof.
  intros x y z.
  apply Dcuts_eq_is_eq.
  intros r ; split.
  - apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; [intros Zr | ]
    | intros zxy ; rewrite (pr1 (pr2 zxy)) ; generalize (pr2 (pr2 (pr2 zxy))) ].
    + apply hinhpr.
      left.
      apply hinhpr.
      left.
      now left.
    + apply hinhfun.
      apply sumofmaps ; [intros Xr | intros Yr].
      * left.
        apply hinhpr.
        left.
        now right.
      * right.
        apply hinhpr.
        left.
        now right.
    + apply hinhfun.
      apply sumofmaps ; [intros Xr | intros Yr].
      * left.
        apply hinhpr.
        right.
        exists (pr1 zxy).
        repeat split.
        exact (pr1 (pr2 (pr2 zxy))).
        exact Xr.
      * right.
        apply hinhpr.
        right.
        exists (pr1 zxy).
        repeat split.
        exact (pr1 (pr2 (pr2 zxy))).
        exact Yr.
  - apply hinhuniv ; apply sumofmaps ; apply hinhuniv ; apply sumofmaps.
    + apply sumofmaps ; [ intros Zr | intros Xr] ; apply hinhpr ; left.
      * now left.
      * right.
        apply hinhpr.
        now left.
    + intros zx ; rewrite (pr1 (pr2 zx)).
      apply hinhpr.
      right.
      exists (pr1 zx).
      repeat split.
      exact (pr1 (pr2 (pr2 zx))).
      apply hinhpr.
      left.
      exact (pr2 (pr2 (pr2 zx))).
    + apply sumofmaps ; [intros Zr | intros Yr] ; apply hinhpr ; left.
      * now left.
      * right.
        apply hinhpr.
        now right.
    + intros zx ; rewrite (pr1 (pr2 zx)).
      apply hinhpr.
      right.
      exists (pr1 zx).
      repeat split.
      exact (pr1 (pr2 (pr2 zx))).
      apply hinhpr.
      right.
      exact (pr2 (pr2 (pr2 zx))).
Qed.

Lemma Dcuts_max_plus :
  Π x y : Dcuts,
    (0 < x -> y = 0) ->
    Dcuts_max x y = Dcuts_plus x y.
Proof.
  intros x y H.
  apply Dcuts_le_ge_eq.
  - intros r.
    apply hinhfun.
    intros H0.
    left.
    exact H0.
  - intros r.
    apply hinhfun.
    apply sumofmaps ; [intros H0 | ].
    exact H0.
    intros xy ; rewrite (pr1 (pr2 xy)).
    apply fromempty.
    refine (Dcuts_zero_empty _ _).
    rewrite <- H.
    apply (pr2 (pr2 (pr2 xy))).
    apply hinhpr.
    exists (pr1 (pr1 xy)).
    split.
    apply Dcuts_zero_empty.
    exact (pr1 (pr2 (pr2 xy))).
Qed.

(** *** Dcuts_min *)

Section Dcuts_min.

  Context (X : hsubtypes NonnegativeRationals).
  Context (X_bot : Dcuts_def_bot X).
  Context (X_open : Dcuts_def_open X).
  Context (X_finite : Dcuts_def_finite X).
  Context (X_error : Dcuts_def_error X).
  Context (Y : hsubtypes NonnegativeRationals).
  Context (Y_bot : Dcuts_def_bot Y).
  Context (Y_open : Dcuts_def_open Y).
  Context (Y_finite : Dcuts_def_finite Y).
  Context (Y_error : Dcuts_def_error Y).

Definition Dcuts_min_val : hsubtypes NonnegativeRationals :=
  λ r : NonnegativeRationals, X r ∧ Y r.

Lemma Dcuts_min_bot : Dcuts_def_bot Dcuts_min_val.
Proof.
  intros r Hr q Hqr.
  split.
  - apply X_bot with (1 := pr1 Hr), Hqr.
  - apply Y_bot with (1 := pr2 Hr), Hqr.
Qed.

Lemma Dcuts_min_open : Dcuts_def_open Dcuts_min_val.
Proof.
  intros r Hr.
  generalize (X_open _ (pr1 Hr)) (Y_open _ (pr2 Hr)).
  apply hinhfun2 ; intros q q'.
  generalize (isdecrel_ltNonnegativeRationals (pr1 q) (pr1 q')) ;
    apply sumofmaps ; intros H.
  - exists (pr1 q) ; repeat split.
    exact (pr1 (pr2 q)).
    apply Y_bot with (1 := pr1 (pr2 q')), lt_leNonnegativeRationals, H.
    exact (pr2 (pr2 q)).
  - exists (pr1 q') ; repeat split.
    apply X_bot with (1 := pr1 (pr2 q)), notlt_geNonnegativeRationals, H.
    exact (pr1 (pr2 q')).
    exact (pr2 (pr2 q')).
Qed.

Lemma Dcuts_min_error : Dcuts_def_error Dcuts_min_val.
Proof.
  intros c Hc0.
  generalize (X_error _ Hc0) (Y_error _ Hc0) ; apply hinhfun2 ; apply (sumofmaps (Z := _ → _)) ; [intros nXc | intros q] ; intros Hy.
  - left ; intros Hc.
    apply nXc.
    exact (pr1 Hc).
  - revert Hy ; apply sumofmaps ;
    [intros nYc | intros q'].
    + left ; intros Hc.
      apply nYc.
      exact (pr2 Hc).
    + right.
      generalize (isdecrel_ltNonnegativeRationals (pr1 q) (pr1 q')) ;
        apply sumofmaps ; intros H.
      * exists (pr1 q) ; repeat split.
        exact (pr1 (pr2 q)).
        apply Y_bot with (1 := pr1 (pr2 q')), lt_leNonnegativeRationals, H.
        intros Hc.
        apply (pr2 (pr2 q)).
        exact (pr1 Hc).
      * exists (pr1 q') ; repeat split.
        apply X_bot with (1 := pr1 (pr2 q)), notlt_geNonnegativeRationals, H.
        exact (pr1 (pr2 q')).
        intros Hc.
        apply (pr2 (pr2 q')).
        exact (pr2 Hc).
Qed.

End Dcuts_min.

Definition Dcuts_min (X Y : Dcuts) : Dcuts :=
  mk_Dcuts (Dcuts_min_val (pr1 X) (pr1 Y))
           (Dcuts_min_bot (pr1 X) (is_Dcuts_bot X)
                          (pr1 Y) (is_Dcuts_bot Y))
           (Dcuts_min_open (pr1 X) (is_Dcuts_bot X) (is_Dcuts_open X)
                           (pr1 Y) (is_Dcuts_bot Y) (is_Dcuts_open Y))
           (Dcuts_min_error (pr1 X) (is_Dcuts_bot X) (is_Dcuts_error X)
                            (pr1 Y) (is_Dcuts_bot Y) (is_Dcuts_error Y)).

Lemma iscomm_Dcuts_min :
  Π x y : Dcuts, Dcuts_min x y = Dcuts_min y x.
Proof.
  intros x y.
  apply Dcuts_eq_is_eq ; intros r.
  split ; apply weqdirprodcomm.
Qed.

Lemma isassoc_Dcuts_min :
  Π x y z : Dcuts, Dcuts_min (Dcuts_min x y) z = Dcuts_min x (Dcuts_min y z).
Proof.
  intros x y z.
  apply Dcuts_eq_is_eq ; intros r.
  split ; intros Hr ; repeat split.
  - apply (pr1 (pr1 Hr)).
  - apply (pr2 (pr1 Hr)).
  - apply (pr2 Hr).
  - apply (pr1 Hr).
  - apply (pr1 (pr2 Hr)).
  - apply (pr2 (pr2 Hr)).
Qed.

Lemma Dcuts_min_le_l :
  Π x y : Dcuts, Dcuts_min x y <= x.
Proof.
  intros x y r Hr.
  exact (pr1 Hr).
Qed.
Lemma Dcuts_min_le_r :
  Π x y : Dcuts, Dcuts_min x y <= y.
Proof.
  intros x y r Hr.
  exact (pr2 Hr).
Qed.

Lemma Dcuts_min_carac_r :
  Π x y : Dcuts, y <= x -> Dcuts_min x y = y.
Proof.
  intros x y Hxy.
  apply Dcuts_eq_is_eq ; intros r ; split.
  - intros Hr.
    exact (pr2 Hr).
  - intros Yr.
    split.
    now apply Hxy.
    exact Yr.
Qed.
Lemma Dcuts_min_carac_l :
  Π x y : Dcuts, x <= y -> Dcuts_min x y = x.
Proof.
  intros x y Hxy.
  rewrite iscomm_Dcuts_min.
  now apply Dcuts_min_carac_r.
Qed.

Lemma Dcuts_min_max :
  Π x y : Dcuts,
    Dcuts_min x (Dcuts_max x y) = x.
Proof.
  intros x y.
  apply Dcuts_eq_is_eq ; intros r.
  split.
  - intros Hr.
    exact (pr1 Hr).
  - intros Xr.
    split.
    exact Xr.
    apply hinhpr.
    now left.
Qed.
Lemma Dcuts_max_min :
  Π x y : Dcuts,
    Dcuts_max x (Dcuts_min x y) = x.
Proof.
  intros x y.
  apply Dcuts_eq_is_eq ; intros r.
  split.
  - apply hinhuniv ; apply sumofmaps ; [intros Xr | intros Hr].
    exact Xr.
    exact (pr1 Hr).
  - intros Xr.
    apply hinhpr.
    now left.
Qed.

Lemma Dcuts_min_gt :
  Π x y z : Dcuts,
    z < x → z < y → z < (Dcuts_min x y).
Proof.
  intros x y z.
  apply hinhfun2.
  intros r q.
  generalize (isdecrel_ltNonnegativeRationals (pr1 r) (pr1 q)) ; apply sumofmaps ; intros H.
  - exists (pr1 r).
    repeat split.
    + exact (pr1 (pr2 r)).
    + exact (pr2 (pr2 r)).
    + apply is_Dcuts_bot with (1 := pr2 (pr2 q)), lt_leNonnegativeRationals, H.
  - exists (pr1 q).
    repeat split.
    + exact (pr1 (pr2 q)).
    + apply is_Dcuts_bot with (1 := pr2 (pr2 r)), notlt_geNonnegativeRationals, H.
    + exact (pr2 (pr2 q)).
Qed.

(** *** Dcuts_half *)

Lemma Dcuts_two_ap_zero : Dcuts_two ≠ 0.
Proof.
  apply isapfun_NonnegativeRationals_to_Dcuts'.
  apply gtNonnegativeRationals_noteq.
  exact ispositive_twoNonnegativeRationals.
Qed.

Section Dcuts_half.

Context (X : hsubtypes NonnegativeRationals)
        (X_bot : Dcuts_def_bot X)
        (X_open : Dcuts_def_open X)
        (X_error : Dcuts_def_error X).

Definition Dcuts_half_val : hsubtypes NonnegativeRationals :=
  λ r, X (r + r).
Lemma Dcuts_half_bot : Dcuts_def_bot Dcuts_half_val.
Proof.
  intros r Hr q Hq.
  apply X_bot with (1 := Hr).
  eapply istrans_leNonnegativeRationals, plusNonnegativeRationals_lecompat_l, Hq.
  now apply plusNonnegativeRationals_lecompat_r, Hq.
Qed.
Lemma Dcuts_half_open : Dcuts_def_open Dcuts_half_val.
Proof.
  intros r Hr.
  generalize (X_open _ Hr).
  apply hinhfun ; intros q.
  exists (pr1 q / 2)%NRat ; split.
  - unfold Dcuts_half_val.
    rewrite <- NQhalf_double.
    exact (pr1 (pr2 q)).
  - apply_pr2 (multNonnegativeRationals_ltcompat_l 2%NRat).
    exact ispositive_twoNonnegativeRationals.
    pattern r at 1 ; rewrite (NQhalf_double r), isldistr_mult_plusNonnegativeRationals, !multdivNonnegativeRationals.
    exact (pr2 (pr2 q)).
    exact ispositive_twoNonnegativeRationals.
    exact ispositive_twoNonnegativeRationals.
Qed.
Lemma Dcuts_half_error : Dcuts_def_error Dcuts_half_val.
Proof.
  intros c Hc.
  assert (Hc0 : (0 < c + c)%NRat)
    by (now apply ispositive_plusNonnegativeRationals_l).
  generalize (X_error _ Hc0) ; apply hinhfun ; apply sumofmaps ; [intros Hx | intros r].
  - left ; exact Hx.
  - right.
    exists (pr1 r / 2)%NRat ; split.
    + unfold Dcuts_half_val.
      rewrite <- NQhalf_double.
      exact (pr1 (pr2 r)).
    + intro H ; apply (pr2 (pr2 r)).
      apply X_bot with (1 := H).
      pattern (pr1 r) at 1 ;
        rewrite (NQhalf_double (pr1 r)), !isassoc_plusNonnegativeRationals.
      apply plusNonnegativeRationals_lecompat_l.
      rewrite iscomm_plusNonnegativeRationals, !isassoc_plusNonnegativeRationals.
      apply plusNonnegativeRationals_lecompat_l.
      rewrite iscomm_plusNonnegativeRationals.
      now apply isrefl_leNonnegativeRationals.
Qed.

End Dcuts_half.

Definition Dcuts_half (x : Dcuts) : Dcuts :=
  mk_Dcuts (Dcuts_half_val (pr1 x))
           (Dcuts_half_bot (pr1 x) (is_Dcuts_bot x))
           (Dcuts_half_open (pr1 x) (is_Dcuts_open x))
           (Dcuts_half_error (pr1 x) (is_Dcuts_bot x) (is_Dcuts_error x)).

Lemma Dcuts_half_le :
  Π x : Dcuts, Dcuts_half x <= x.
Proof.
  intros x.
  intros r Hr.
  apply is_Dcuts_bot with (1 := Hr).
  now apply plusNonnegativeRationals_le_l.
Qed.

Lemma isdistr_Dcuts_half_plus :
  Π x y : Dcuts, Dcuts_half (Dcuts_plus x y) = Dcuts_plus (Dcuts_half x) (Dcuts_half y).
Proof.
  intros x y.
  apply Dcuts_eq_is_eq.
  intros r ; split.
  - apply hinhfun ; apply sumofmaps ; [apply sumofmaps ; [intros Xr | intros Yr] | intros xy ].
    + left.
      left.
      exact Xr.
    + left.
      right.
      exact Yr.
    + right.
      exists (pr1 (pr1 xy) / 2%NRat,, pr2 (pr1 xy)/2%NRat).
      unfold Dcuts_half_val ; simpl ; repeat split.
      * unfold divNonnegativeRationals.
        rewrite <- isrdistr_mult_plusNonnegativeRationals.
        pattern r at 1 ;
          rewrite (NQhalf_double r) ; unfold divNonnegativeRationals ; rewrite <- isrdistr_mult_plusNonnegativeRationals.
        apply (maponpaths (λ x, x * _)), (pr1 (pr2 xy)).
      * unfold Dcuts_half_val ;
        rewrite <- NQhalf_double.
        exact (pr1 (pr2 (pr2 xy))).
      * unfold Dcuts_half_val ;
        rewrite <- NQhalf_double.
        exact (pr2 (pr2 (pr2 xy))).
  - apply hinhfun ; apply sumofmaps ; [apply sumofmaps ; [intros Xr | intros Yr] | intros xy ; rewrite (pr1 (pr2 xy))].
    + left.
      left.
      exact Xr.
    + left.
      right.
      exact Yr.
    + right.
      exists (pr1 (pr1 xy) + pr1 (pr1 xy),, pr2 (pr1 xy) + pr2 (pr1 xy)).
      simpl ; repeat split.
      * rewrite !isassoc_plusNonnegativeRationals.
        apply maponpaths.
        rewrite iscomm_plusNonnegativeRationals, isassoc_plusNonnegativeRationals.
        reflexivity.
      * exact (pr1 (pr2 (pr2 xy))).
      * exact (pr2 (pr2 (pr2 xy))).
Qed.
Lemma Dcuts_half_double :
  Π x : Dcuts, x = Dcuts_plus (Dcuts_half x) (Dcuts_half x).
Proof.
  intros x.
  rewrite  <- isdistr_Dcuts_half_plus.
  apply Dcuts_eq_is_eq ; split.
  - intros Hr.
    apply hinhpr ; right ; exists (r,,r).
    now repeat split.
  - apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps | intros xy ].
    + now apply Dcuts_half_le.
    + now apply Dcuts_half_le.
    + generalize (isdecrel_ltNonnegativeRationals r (pr1 (pr1 xy))) ; apply sumofmaps ; intro Hrx.
      apply is_Dcuts_bot with (1 := pr1 (pr2 (pr2 xy))).
      now apply lt_leNonnegativeRationals.
      apply is_Dcuts_bot with (1 := pr2 (pr2 (pr2 xy))).
      apply_pr2 (plusNonnegativeRationals_lecompat_l r).
      pattern (r+r) at 1 ;
        rewrite (pr1 (pr2 xy)).
      apply plusNonnegativeRationals_lecompat_r.
      now apply notlt_geNonnegativeRationals.
Qed.

Lemma Dcuts_half_correct :
  Π x, Dcuts_half x = Dcuts_mult x (Dcuts_inv Dcuts_two Dcuts_two_ap_zero).
Proof.
  intros x.
  pattern x at 2 ; rewrite (Dcuts_half_double x).
  rewrite Dcuts_plus_double, iscomm_Dcuts_mult, <- isassoc_Dcuts_mult, islinv_Dcuts_inv, islunit_Dcuts_mult_one.
  reflexivity.
Qed.

Lemma ispositive_Dcuts_half:
  Π x : Dcuts, (0 < x) <-> (0 < Dcuts_half x).
Proof.
  intros.
  rewrite Dcuts_half_correct.
  pattern 0 at 2 ; rewrite <- (islabsorb_Dcuts_mult_zero (Dcuts_inv Dcuts_two Dcuts_two_ap_zero)).
  split.
  - intro Hx0.
    apply Dcuts_mult_ltcompat_l.
    apply Dcuts_mult_ltcompat_l' with Dcuts_two.
    rewrite islabsorb_Dcuts_mult_zero, islinv_Dcuts_inv.
    unfold Dcuts_zero, Dcuts_one.
    apply (pr2 (isapfun_NonnegativeRationals_to_Dcuts_aux 0%NRat 1%NRat)).
    now apply ispositive_oneNonnegativeRationals.
    exact Hx0.
  - now apply Dcuts_mult_ltcompat_l'.
Qed.

(** ** Locatedness *)

Lemma Dcuts_locatedness :
  Π X : Dcuts, Π p q : NonnegativeRationals, (p < q)%NRat -> p ∈ X ∨ ¬ (q ∈ X).
Proof.
  intros X p q Hlt.
  apply ispositive_minusNonnegativeRationals in Hlt.
  generalize (is_Dcuts_error X _ Hlt).
  apply_pr2_in ispositive_minusNonnegativeRationals Hlt.
  apply hinhuniv ; apply sumofmaps ; [ intros Xr | ].
  - apply hinhpr ; right.
    intro H ; apply Xr.
    apply is_Dcuts_bot with (1 := H).
    now apply minusNonnegativeRationals_le.
  - intros r.
    generalize (isdecrel_leNonnegativeRationals p (pr1 r)) ; apply sumofmaps ; [ intros Hle | intros Hnle].
    + apply hinhpr ; left.
      now apply is_Dcuts_bot with (1 := pr1 (pr2 r)).
    + apply notge_ltNonnegativeRationals in Hnle.
      apply hinhpr ; right.
      intro H ; apply (pr2 (pr2 r)).
      apply is_Dcuts_bot with (1 := H).
      apply_pr2 (plusNonnegativeRationals_lecompat_r p).
      rewrite isassoc_plusNonnegativeRationals, minusNonnegativeRationals_plus_r, iscomm_plusNonnegativeRationals.
      apply plusNonnegativeRationals_lecompat_l.
      now apply lt_leNonnegativeRationals.
      now apply lt_leNonnegativeRationals.
Qed.

(** ** Limits of Cauchy sequences *)

Section Dcuts_lim.

Context (U : nat -> hsubtypes NonnegativeRationals)
        (U_bot : Π n : nat, Dcuts_def_bot (U n))
        (U_open : Π n : nat, Dcuts_def_open (U n))
        (U_error : Π n : nat, Dcuts_def_error (U n)).

Context (U_cauchy :
           Π eps : NonnegativeRationals,
                   (0 < eps)%NRat ->
                   hexists
                     (λ N : nat,
                            Π n m : nat, N ≤ n -> N ≤ m -> (Π r, U n r -> Dcuts_plus_val (U m) (λ q, (q < eps)%NRat) r) × (Π r, U m r -> Dcuts_plus_val (U n) (λ q, (q < eps)%NRat) r))).

Definition Dcuts_lim_cauchy_val : hsubtypes NonnegativeRationals :=
λ r : NonnegativeRationals, hexists (λ c : NonnegativeRationals, (0 < c)%NRat × Σ N : nat, Π n : nat, N ≤ n -> U n (r + c)).

Lemma Dcuts_lim_cauchy_bot : Dcuts_def_bot Dcuts_lim_cauchy_val.
Proof.
  intros r Hr q Hq.
  revert Hr ; apply hinhfun ; intros c.
  exists (pr1 c) ; split.
  exact (pr1 (pr2 c)).
  exists (pr1 (pr2 (pr2 c))) ; intros n Hn.
  apply (U_bot n) with (1 := pr2 (pr2 (pr2 c)) n Hn).
  apply plusNonnegativeRationals_lecompat_r.
  exact Hq.
Qed.
Lemma Dcuts_lim_cauchy_open : Dcuts_def_open Dcuts_lim_cauchy_val.
Proof.
  intros r.
  apply hinhfun ; intros c.
  exists (r + (pr1 c / 2))%NRat ; split.
  - apply hinhpr.
    exists (pr1 c / 2)%NRat ; split.
    + now apply ispositive_NQhalf, (pr1 (pr2 c)).
    + exists (pr1 (pr2 (pr2 c))) ; intros n Hn.
      rewrite isassoc_plusNonnegativeRationals, <- NQhalf_double.
      now apply (pr2 (pr2 (pr2 c))).
  - apply plusNonnegativeRationals_lt_r, ispositive_NQhalf.
    exact (pr1 (pr2 c)).
Qed.
Lemma Dcuts_lim_cauchy_error : Dcuts_def_error Dcuts_lim_cauchy_val.
Proof.
  intros c Hc.
  apply ispositive_NQhalf, ispositive_NQhalf in Hc.
  generalize (U_cauchy _ Hc) ; clear U_cauchy ; apply hinhuniv ; intros N.
  generalize (λ n Hn, pr2 N n (pr1 N) Hn (isreflnatleh _)) ; intro Hu.
  generalize (U_error (pr1 N) _ Hc).
  apply hinhuniv ; apply sumofmaps ; intros HuN.
  - apply hinhpr ; left.
    intro ; apply HuN ; clear HuN.
    revert X ; apply hinhuniv ; intros eps.
    generalize (natgthorleh (pr1 N) (pr1 (pr2 (pr2 eps)))) ; apply sumofmaps ; intros HN.
    + apply natlthtoleh in HN.
      apply (U_bot (pr1 N)) with (1 := pr2 (pr2 (pr2 eps)) _ HN).
      pattern c at 2 ;
        rewrite (NQhalf_double c), isassoc_plusNonnegativeRationals.
      pattern (c / 2)%NRat at 2 ;
        rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
      now apply plusNonnegativeRationals_le_r.
    + generalize (pr2 (pr2 (pr2 eps)) _ (isreflnatleh _)) ; intros HuN'.
      generalize (pr1 (Hu _ HN) _ HuN') ; clear Hu HuN'.
      apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; intros H | intros xy ].
      * apply (U_bot (pr1 N)) with (1 := H).
        pattern c at 2 ;
          rewrite (NQhalf_double c), isassoc_plusNonnegativeRationals.
      pattern (c / 2)%NRat at 2 ;
        rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
        now apply plusNonnegativeRationals_le_r.
      * apply fromempty.
        revert H.
        apply_pr2 notlt_geNonnegativeRationals.
        pattern c at 2 ;
          rewrite (NQhalf_double c), isassoc_plusNonnegativeRationals.
        pattern (c / 2)%NRat at 2 ;
          rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
        now apply plusNonnegativeRationals_le_r.
      * apply (U_bot (pr1 N)) with (1 := pr1 (pr2 (pr2 xy))).
        apply_pr2 (plusNonnegativeRationals_lecompat_r (pr2 (pr1 xy))).
        rewrite <- (pr1 (pr2 xy)).
        pattern c at 7 ;
          rewrite (NQhalf_double c), isassoc_plusNonnegativeRationals.
        pattern (c / 2)%NRat at 5 ;
          rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
        apply plusNonnegativeRationals_lecompat_l.
        apply istrans_leNonnegativeRationals with (c / 2 / 2)%NRat.
        apply lt_leNonnegativeRationals.
        exact (pr2 (pr2 (pr2 xy))).
        now apply plusNonnegativeRationals_le_r.
  - rename HuN into q.
    generalize (isdecrel_leNonnegativeRationals (pr1 q) (c / 2)%NRat) ; apply sumofmaps ; intros Hq.
    + apply hinhpr ; left.
      intro ; apply (pr2 (pr2 q)).
      revert X ; apply hinhuniv ; intros eps.
      generalize (natgthorleh (pr1 N) (pr1 (pr2 (pr2 eps)))) ; apply sumofmaps ; intros HN.
      * apply natlthtoleh in HN.
        apply (U_bot (pr1 N)) with (1 := pr2 (pr2 (pr2 eps)) _ HN).
        pattern c at 7 ;
          rewrite (NQhalf_double c), isassoc_plusNonnegativeRationals.
        apply istrans_leNonnegativeRationals with (c / 2 + c / 2 / 2)%NRat.
        apply plusNonnegativeRationals_lecompat_r.
        exact Hq.
        apply plusNonnegativeRationals_lecompat_l.
        pattern (c / 2)%NRat at 2 ;
          rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
        now apply plusNonnegativeRationals_le_r.
      * generalize (pr2 (pr2 (pr2 eps)) _ (isreflnatleh _)) ; intros HuN'.
        generalize (pr1 (Hu _ HN) _ HuN') ; clear Hu HuN'.
        apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; intros H | intros xy].
        { apply (U_bot (pr1 N)) with (1 := H).
          pattern c at 7 ;
            rewrite (NQhalf_double c), isassoc_plusNonnegativeRationals, iscomm_plusNonnegativeRationals.
          apply istrans_leNonnegativeRationals with (c / 2 / 2 + c / 2)%NRat.
          apply plusNonnegativeRationals_lecompat_l.
          exact Hq.
          rewrite iscomm_plusNonnegativeRationals.
          apply plusNonnegativeRationals_lecompat_l.
          pattern (c / 2)%NRat at 2 ;
            rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
          now apply plusNonnegativeRationals_le_r. }
        { apply fromempty.
          revert H.
          apply_pr2 notlt_geNonnegativeRationals.
          pattern c at 2 ;
            rewrite (NQhalf_double c), isassoc_plusNonnegativeRationals.
          pattern (c / 2)%NRat at 2 ;
            rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
          now apply plusNonnegativeRationals_le_r. }
        { apply (U_bot (pr1 N)) with (1 := pr1 (pr2 (pr2 xy))).
          apply_pr2 (plusNonnegativeRationals_lecompat_r (pr2 (pr1 xy))).
          rewrite <- (pr1 (pr2 xy)).
          pattern c at 12 ;
            rewrite (NQhalf_double c), !isassoc_plusNonnegativeRationals.
          eapply istrans_leNonnegativeRationals.
          apply plusNonnegativeRationals_lecompat_r.
          now apply Hq.
          apply plusNonnegativeRationals_lecompat_l.
          pattern (c / 2)%NRat at 5 ;
            rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
          apply plusNonnegativeRationals_lecompat_l.
          apply istrans_leNonnegativeRationals with (c / 2 / 2)%NRat.
          apply lt_leNonnegativeRationals.
          exact (pr2 (pr2 (pr2 xy))).
          now apply plusNonnegativeRationals_le_r. }
    +  apply hinhpr ; right.
      apply notge_ltNonnegativeRationals in Hq.
      exists (pr1 q - c / 2)%NRat ; split.
      * apply hinhpr.
        exists (c / 2 / 2)%NRat ; split.
        exact Hc.
        exists (pr1 N) ; intros n Hn.
        generalize (pr2 (Hu _ Hn) _ (pr1 (pr2 q))).
        apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; [intros Xr | intros Yr] | intros xy].
        { apply (U_bot n) with (1 := Xr).
          pattern (pr1 q) at 2 ;
            rewrite <- (minusNonnegativeRationals_plus_r (c / 2)%NRat (pr1 q)).
          apply plusNonnegativeRationals_lecompat_l.
          pattern (c / 2)%NRat at 2 ;
            rewrite (NQhalf_double (c / 2)%NRat).
          now apply plusNonnegativeRationals_le_r.
          now apply lt_leNonnegativeRationals. }
        { apply fromempty.
          revert Yr.
          apply_pr2 notlt_geNonnegativeRationals.
          eapply istrans_leNonnegativeRationals, lt_leNonnegativeRationals, Hq.
          pattern (c / 2)%NRat at 2 ;
            rewrite (NQhalf_double (c / 2)%NRat).
          now apply plusNonnegativeRationals_le_r. }
        { apply (U_bot n) with (1 := pr1 (pr2 (pr2 xy))).
          apply_pr2 (plusNonnegativeRationals_lecompat_r (pr2 (pr1 xy))).
          rewrite <- (pr1 (pr2 xy)).
          pattern (pr1 q) at 3 ;
            rewrite <- (minusNonnegativeRationals_plus_r (c / 2)%NRat (pr1 q)), isassoc_plusNonnegativeRationals.
          apply plusNonnegativeRationals_lecompat_l.
          pattern (c / 2)%NRat at 8 ;
            rewrite (NQhalf_double (c / 2)%NRat).
          apply plusNonnegativeRationals_lecompat_l.
          apply lt_leNonnegativeRationals.
          exact (pr2 (pr2 (pr2 xy))).
          now apply lt_leNonnegativeRationals. }
      * intro ; apply (pr2 (pr2 q)).
        revert X ; apply hinhuniv ; intros eps.
        generalize (natgthorleh (pr1 N) (pr1 (pr2 (pr2 eps)))) ; apply sumofmaps ; intros HN.
        { apply natlthtoleh in HN.
          apply (U_bot (pr1 N)) with (1 := pr2 (pr2 (pr2 eps)) _ HN).
          pattern c at 13 ;
            rewrite (NQhalf_double c), <- isassoc_plusNonnegativeRationals, minusNonnegativeRationals_plus_r.
          pattern (c / 2)%NRat at 12 ;
            rewrite (NQhalf_double (c / 2)%NRat), !isassoc_plusNonnegativeRationals, <- (isassoc_plusNonnegativeRationals (pr1 q) (c / 2 / 2)%NRat).
          now apply plusNonnegativeRationals_le_r.
          now apply lt_leNonnegativeRationals. }
        { generalize (pr2 (pr2 (pr2 eps)) _ (isreflnatleh _)) ; intros HuN.
          generalize (pr1 (Hu _ HN) _ HuN) ; clear Hu HuN.
          apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; intros H | intros xy].
          - apply (U_bot (pr1 N)) with (1 := H).
            pattern (pr1 q) at 1 ;
            rewrite <- (minusNonnegativeRationals_plus_r (c / 2)%NRat (pr1 q)), !isassoc_plusNonnegativeRationals.
            apply plusNonnegativeRationals_lecompat_l.
            pattern c at 3 ;
              rewrite (NQhalf_double c), isassoc_plusNonnegativeRationals.
            apply plusNonnegativeRationals_lecompat_l.
            pattern (c / 2)%NRat at 2 ;
              rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
            now apply plusNonnegativeRationals_le_r.
            now apply lt_leNonnegativeRationals.
          -  apply fromempty.
             revert H.
             apply_pr2 notlt_geNonnegativeRationals.
             eapply istrans_leNonnegativeRationals, plusNonnegativeRationals_le_r.
             eapply istrans_leNonnegativeRationals, plusNonnegativeRationals_le_l.
             pattern c at 2 ;
               rewrite (NQhalf_double c).
             pattern (c / 2)%NRat at 2 ;
               rewrite (NQhalf_double (c / 2)%NRat), isassoc_plusNonnegativeRationals.
             now apply plusNonnegativeRationals_le_r.
          - apply (U_bot (pr1 N)) with (1 := pr1 (pr2 (pr2 xy))).
            apply_pr2 (plusNonnegativeRationals_lecompat_r (pr2 (pr1 xy))).
            rewrite <- (pr1 (pr2 xy)).
            pattern (pr1 q) at 1 ;
              rewrite <- (minusNonnegativeRationals_plus_r (c / 2)%NRat (pr1 q)), !isassoc_plusNonnegativeRationals.
            pattern (pr1 q - c / 2 + c + pr1 eps)%NRat at 2 ;
              rewrite (isassoc_plusNonnegativeRationals (pr1 q - c / 2)%NRat c (pr1 eps)).
            apply plusNonnegativeRationals_lecompat_l.
            pattern c at 20 ;
              rewrite (NQhalf_double c).
            pattern (c / 2 + c / 2 + pr1 eps)%NRat at 1 ;
            rewrite isassoc_plusNonnegativeRationals.
            apply plusNonnegativeRationals_lecompat_l.
            pattern (c / 2)%NRat at 17 ;
              rewrite (NQhalf_double (c / 2)%NRat).
            pattern (c / 2 / 2 + c / 2 / 2 + pr1 eps)%NRat at 1 ;
              rewrite isassoc_plusNonnegativeRationals.
            apply plusNonnegativeRationals_lecompat_l.
            apply istrans_leNonnegativeRationals with (c / 2 / 2)%NRat.
            apply lt_leNonnegativeRationals.
            exact (pr2 (pr2 (pr2 xy))).
            now apply plusNonnegativeRationals_le_r.
            now apply lt_leNonnegativeRationals. }
Qed.

End Dcuts_lim.

Definition Dcuts_Cauchy_seq (u : nat -> Dcuts) : hProp
  := hProppair (Π eps : Dcuts,
                   0 < eps ->
                   hexists
                     (λ N : nat,
                            Π n m : nat, N ≤ n -> N ≤ m -> u n < Dcuts_plus (u m) eps × u m < Dcuts_plus (u n) eps))
               (impred_isaprop _ (λ _, isapropimpl _ _ (pr2 _))).
Definition is_Dcuts_lim_seq (u : nat -> Dcuts) (l : Dcuts) : hProp
  := hProppair (Π eps : Dcuts,
                   0 < eps ->
                   hexists
                     (λ N : nat,
                            Π n : nat, N ≤ n -> u n < Dcuts_plus l eps × l < Dcuts_plus (u n) eps))
               (impred_isaprop _ (λ _, isapropimpl _ _ (pr2 _))).

Definition Dcuts_lim_cauchy_seq (u : nat → Dcuts) (Hu : Dcuts_Cauchy_seq u) : Dcuts.
Proof.
  intros U HU.
  exists (Dcuts_lim_cauchy_val (fun n => pr1 (U n))).
  repeat split.
  - apply Dcuts_lim_cauchy_bot.
    intro ; now apply is_Dcuts_bot.
  - apply Dcuts_lim_cauchy_open.
  - apply Dcuts_lim_cauchy_error.
    + intro ; now apply is_Dcuts_bot.
    + intro ; now apply is_Dcuts_error.
    + intros eps Heps.
      assert (0 < NonnegativeRationals_to_Dcuts eps)
        by (now apply_pr2 isapfun_NonnegativeRationals_to_Dcuts_aux).
      generalize (HU _ X) ; clear HU.
      apply hinhfun ; intros HU.
      exists (pr1 HU) ; intros n m Hn Hm.
      set (pr2 HU n m Hn Hm) ; clearbody d ; clear -d ; rename d into HU.
      split.
      * now refine (Dcuts_lt_le_rel _ _ (pr1 HU)).
      * now refine (Dcuts_lt_le_rel _ _ (pr2 HU)).
Defined.

Lemma Dcuts_Cauchy_seq_impl_ex_lim_seq (u : nat → Dcuts) (Hu : Dcuts_Cauchy_seq u) :
  is_Dcuts_lim_seq u (Dcuts_lim_cauchy_seq u Hu).
Proof.
  intros U HU eps.
  apply hinhuniv ; intros c'.
  generalize (is_Dcuts_open _ _ (pr2 (pr2 c'))).
  apply hinhuniv ; intros c.
  assert (Hc0 : (0 < pr1 c)%NRat).
  { eapply istrans_le_lt_ltNonnegativeRationals, (pr2 (pr2 c)).
    now apply isnonnegative_NonnegativeRationals. }
  apply ispositive_NQhalf in Hc0.
  generalize (HU _ (pr2 (isapfun_NonnegativeRationals_to_Dcuts_aux _ _) Hc0)).
  apply hinhfun ; intros N.
  exists (pr1 N) ; intros n Hn.
  generalize (λ n Hn, pr2 N n (pr1 N) Hn (isreflnatleh _)) ; intros Hu.
  split.
  - eapply istrans_Dcuts_lt_le_rel.
    now apply (Hu n Hn).
    pattern eps at 7 ;
      rewrite (Dcuts_half_double eps), <- isassoc_Dcuts_plus.
    eapply istrans_Dcuts_le_rel, Dcuts_plus_lecompat_l.
    + apply Dcuts_plus_lecompat_r.
      intros r Hr.
      simpl.
      apply is_Dcuts_bot with (1 := pr1 (pr2 c)).
      rewrite (NQhalf_double (pr1 c)).
      now apply lt_leNonnegativeRationals, plusNonnegativeRationals_ltcompat ; apply Hr.
    + intros r Hr.
      generalize (isdecrel_ltNonnegativeRationals r (pr1 c / 2)%NRat) ; apply sumofmaps ; intro Hrc.
      * apply hinhpr ; left ; right.
        apply is_Dcuts_bot with (1 := pr1 (pr2 c)).
        rewrite (NQhalf_double (pr1 c)).
        now apply lt_leNonnegativeRationals, plusNonnegativeRationals_ltcompat ; apply Hrc.
      * apply notlt_geNonnegativeRationals in Hrc.
        generalize (is_Dcuts_open _ _ Hr).
        apply hinhuniv ; intros q.
        apply hinhpr ; right ; exists (r - pr1 c / 2%NRat,, pr1 c / 2%NRat) ; repeat split.
        now simpl ; rewrite minusNonnegativeRationals_plus_r.
        generalize (pr1 q) (pr1 (pr2 q)) (pr2 (pr2 q)) ; clear q ; intros q UNq Hrq.
        apply hinhpr ; exists (q - r) ; split.
        apply ispositive_minusNonnegativeRationals, Hrq.
        exists (pr1 N) ; intros m Hm.
        simpl.
        rewrite minusNonnegativeRationals_plus_exchange, iscomm_plusNonnegativeRationals, minusNonnegativeRationals_plus_r.
        generalize (Dcuts_lt_le_rel _ _ (pr2 (Hu m Hm)) _ UNq) ; clear Hu.
        apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; [ intros Xr | intros Yr] | intros xy ; rewrite (pr1 (pr2 xy))].
        apply is_Dcuts_bot with (1 := Xr).
        now apply minusNonnegativeRationals_le.
        simpl in Yr.
        apply_pr2_in notge_ltNonnegativeRationals Yr.
        apply fromempty, Yr.
        apply istrans_leNonnegativeRationals with r.
        exact Hrc.
        now apply lt_leNonnegativeRationals.
        apply is_Dcuts_bot with (1 := pr1 (pr2 (pr2 xy))).
        apply_pr2 (plusNonnegativeRationals_lecompat_r (pr1 c / 2)%NRat).
        rewrite minusNonnegativeRationals_plus_r.
        apply plusNonnegativeRationals_lecompat_l, lt_leNonnegativeRationals.
        exact (pr2 (pr2 (pr2 xy))).
        apply lt_leNonnegativeRationals.
        rewrite <- (pr1 (pr2 xy)).
        eapply istrans_le_lt_ltNonnegativeRationals, Hrq.
        exact Hrc.
        now apply lt_leNonnegativeRationals.
        exact Hrc.
        simpl ; unfold Dcuts_half_val.
        rewrite <- NQhalf_double.
        exact (pr1 (pr2 c)).
  - apply istrans_Dcuts_le_lt_rel with (Dcuts_plus (U (pr1 N)) (Dcuts_half eps)).
    + intros r.
      apply hinhuniv ; intros c''.
      generalize (isdecrel_ltNonnegativeRationals r (pr1 c / 2)%NRat) ; apply sumofmaps ; intro Hrc.
      * apply hinhpr ; left ; right.
        apply is_Dcuts_bot with (1 := pr1 (pr2 c)).
        rewrite (NQhalf_double (pr1 c)).
        now apply lt_leNonnegativeRationals, plusNonnegativeRationals_ltcompat ; apply Hrc.
      * apply notlt_geNonnegativeRationals in Hrc.
        apply hinhpr ; right ; exists (r - pr1 c / 2%NRat,, pr1 c / 2%NRat) ; simpl ; repeat split.
        now rewrite minusNonnegativeRationals_plus_r.
        generalize (natgthorleh (pr1 N) (pr1 (pr2 (pr2 c'')))) ; apply sumofmaps ; intro HN.
        { apply natlthtoleh in HN.
          apply is_Dcuts_bot with (1 := pr2 (pr2 (pr2 c'')) _ HN).
          apply istrans_leNonnegativeRationals with r.
          now apply minusNonnegativeRationals_le.
          now apply plusNonnegativeRationals_le_r. }
        { generalize (Dcuts_lt_le_rel _ _ (pr1 (Hu _ HN)) _ (pr2 (pr2 (pr2 c'')) _ (isreflnatleh _))).
          apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; [intros Xr | intros Yr] | intros xy ].
          - apply is_Dcuts_bot with (1 := Xr).
            apply istrans_leNonnegativeRationals with r.
            now apply minusNonnegativeRationals_le.
            now apply plusNonnegativeRationals_le_r.
          - apply_pr2_in notge_ltNonnegativeRationals Yr.
            apply fromempty, Yr.
            apply istrans_leNonnegativeRationals with r.
            exact Hrc.
            now apply plusNonnegativeRationals_le_r.
          - apply is_Dcuts_bot with (1 := pr1 (pr2 (pr2 xy))).
            apply_pr2 (plusNonnegativeRationals_lecompat_r (pr1 c / 2)%NRat).
            rewrite minusNonnegativeRationals_plus_r.
            apply istrans_leNonnegativeRationals with (r + pr1 c'').
            now apply plusNonnegativeRationals_le_r.
            pattern (r + pr1 c'') at 1 ;
              rewrite (pr1 (pr2 xy)).
            apply plusNonnegativeRationals_lecompat_l.
            apply lt_leNonnegativeRationals.
            exact (pr2 (pr2 (pr2 xy))).
            exact Hrc. }
        unfold Dcuts_half_val.
        rewrite <- NQhalf_double.
        exact (pr1 (pr2 c)).
    + pattern eps at 6 ;
      rewrite (Dcuts_half_double eps), <- isassoc_Dcuts_plus.
      apply Dcuts_plus_ltcompat_l.
      apply istrans_Dcuts_lt_le_rel with (Dcuts_plus (U n) (NonnegativeRationals_to_Dcuts (pr1 c / 2)%NRat)).
      now apply (pr2 (Hu _ Hn)).
      apply Dcuts_plus_lecompat_r.
      intros r Hr.
      apply is_Dcuts_bot with (1 := pr1 (pr2 c)).
      rewrite (NQhalf_double (pr1 c)).
      apply lt_leNonnegativeRationals, plusNonnegativeRationals_ltcompat ; apply Hr.
Qed.

(** ** Dedekind Completeness *)

Section Dcuts_of_Dcuts.

Context (E : hsubtypes Dcuts).
Context (E_bot : Π x : Dcuts, E x -> Π y : Dcuts, y <= x -> E y).
Context (E_open : Π x : Dcuts, E x -> ∃ y : Dcuts, x < y × E y).
Context (E_error: Π c : Dcuts, 0 < c -> (¬ E c) ∨ (hexists (λ P, E P × ¬ E (Dcuts_plus P c)))).

Definition Dcuts_of_Dcuts_val : NonnegativeRationals → hProp :=
  λ r : NonnegativeRationals, ∃ X : Dcuts, (E X) × (r ∈ X).

Lemma Dcuts_of_Dcuts_bot :
  Π (x : NonnegativeRationals),
    Dcuts_of_Dcuts_val x -> Π y : NonnegativeRationals, (y <= x)%NRat -> Dcuts_of_Dcuts_val y.
Proof.
  intros r Xr n Xn.
  revert Xr ; apply hinhfun ; intros X.
  exists (pr1 X) ; split.
  exact (pr1 (pr2 X)).
  apply is_Dcuts_bot with r.
  exact (pr2 (pr2 X)).
  exact Xn.
Qed.

Lemma Dcuts_of_Dcuts_open :
  Π (x : NonnegativeRationals),
    Dcuts_of_Dcuts_val x ->
    hexists (fun y : NonnegativeRationals => dirprod (Dcuts_of_Dcuts_val y) (x < y)%NRat).
Proof.
  intros r.
  apply hinhuniv ; intros X.
  generalize (is_Dcuts_open _ _ (pr2 (pr2 X))).
  apply hinhfun ; intros n.
  exists (pr1 n) ; split.
  apply hinhpr.
  exists (pr1 X) ; split.
  exact (pr1 (pr2 X)).
  exact (pr1 (pr2 n)).
  exact (pr2 (pr2 n)).
Qed.

Lemma Dcuts_of_Dcuts_error:
  Dcuts_def_error Dcuts_of_Dcuts_val.
Proof.
  intros c Hc.
  apply ispositive_NQhalf in Hc.
  apply (pr2 (isapfun_NonnegativeRationals_to_Dcuts_aux _ _)) in Hc.
  generalize (E_error _ Hc).
  apply isapfun_NonnegativeRationals_to_Dcuts_aux in Hc.
  apply hinhuniv ; apply sumofmaps ; [intros He | ].
  - apply hinhpr ; left.
    unfold neg ; apply hinhuniv'.
    exact isapropempty.
    intros X.
    apply He.
    apply E_bot with (1 := pr1 (pr2 X)).
    intros r Hr.
    apply is_Dcuts_bot with c.
    exact (pr2 (pr2 X)).
    apply lt_leNonnegativeRationals.
    eapply istrans_lt_le_ltNonnegativeRationals.
    exact Hr.
    pattern c at 2 ;
      rewrite (NQhalf_double c).
    apply plusNonnegativeRationals_le_r.
  - apply hinhuniv ; intros X.
    generalize (is_Dcuts_error (pr1 X) _ Hc).
    apply hinhfun ; apply sumofmaps ; [intros Xc | ].
    + left.
      unfold neg ; apply hinhuniv'.
      exact isapropempty.
      intros Y.
      apply (pr2 (pr2 X)).
      apply E_bot with (1 := pr1 (pr2 Y)).
      apply Dcuts_lt_le_rel.
      apply hinhpr.
      exists c ; split.
      2: exact (pr2 (pr2 Y)).
      intros H ; apply Xc.
      revert H ; apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; [intros Xc' | intros Yc'] | ].
      * apply is_Dcuts_bot with (1 := Xc').
        pattern c at 2.
        rewrite (NQhalf_double c).
        apply plusNonnegativeRationals_le_r.
      * apply fromempty.
        revert Yc' ; simpl.
        change (¬ (c < c / 2)%NRat).
        apply (pr2 (notlt_geNonnegativeRationals _ _)).
        pattern c at 2.
        rewrite (NQhalf_double c).
        apply plusNonnegativeRationals_le_r.
      * intros xy.
        apply is_Dcuts_bot with (1 := pr1 (pr2 (pr2 xy))).
        apply_pr2 (plusNonnegativeRationals_lecompat_r (pr2 (pr1 xy))).
        rewrite <- (pr1 (pr2 xy)).
        pattern c at 5 ; rewrite (NQhalf_double c).
        apply plusNonnegativeRationals_lecompat_l.
        apply lt_leNonnegativeRationals.
        exact (pr2 (pr2 (pr2 xy))).
    + intro ; right.
      rename X0 into q.
      exists (pr1 q) ; split.
      apply hinhpr.
      exists (pr1 X) ; split.
      exact (pr1 (pr2 X)).
      exact (pr1 (pr2 q)).
      unfold neg ; apply hinhuniv'.
      exact isapropempty.
      intros Y.
      apply (pr2 (pr2 X)).
      apply E_bot with (1 := pr1 (pr2 Y)).
      intros r.
      apply hinhuniv ; apply sumofmaps.
      apply sumofmaps ; [intros Xc' | intros Yc' ].
      * apply is_Dcuts_bot with (1 := pr2 (pr2 Y)).
        pattern c at 4 ;
          rewrite (NQhalf_double c).
        rewrite <- isassoc_plusNonnegativeRationals.
        eapply istrans_leNonnegativeRationals, plusNonnegativeRationals_le_r.
        apply lt_leNonnegativeRationals.
        apply notge_ltNonnegativeRationals.
        intro ; apply (pr2 (pr2 q)).
        now apply is_Dcuts_bot with (1 := Xc').
      * apply is_Dcuts_bot with (1 := pr2 (pr2 Y)).
        pattern c at 4 ;
          rewrite (NQhalf_double c).
        rewrite <- isassoc_plusNonnegativeRationals.
        eapply istrans_leNonnegativeRationals, plusNonnegativeRationals_le_l.
        apply lt_leNonnegativeRationals.
        exact Yc'.
      * intros xy.
        apply is_Dcuts_bot with (1 := pr2 (pr2 Y)).
        rewrite (pr1 (pr2 xy)).
        pattern c at 8 ;
          rewrite (NQhalf_double c).
        rewrite <- isassoc_plusNonnegativeRationals.
        eapply istrans_leNonnegativeRationals, plusNonnegativeRationals_lecompat_l.
        apply plusNonnegativeRationals_lecompat_r.
        apply lt_leNonnegativeRationals, notge_ltNonnegativeRationals.
        intro ; apply (pr2 (pr2 q)).
        now apply is_Dcuts_bot with (1 := pr1 (pr2 (pr2 xy))).
        apply lt_leNonnegativeRationals.
        exact (pr2 (pr2 (pr2 xy))).
Qed.

End Dcuts_of_Dcuts.

Definition Dcuts_of_Dcuts (E : hsubtypes Dcuts) E_bot E_error : Dcuts :=
  mk_Dcuts (Dcuts_of_Dcuts_val E) (Dcuts_of_Dcuts_bot E) (Dcuts_of_Dcuts_open E) (Dcuts_of_Dcuts_error E E_bot E_error).

Section Dcuts_of_Dcuts'.

Context (E : hsubtypes NonnegativeRationals).
Context (E_bot : Dcuts_def_bot E).
Context (E_open : Dcuts_def_open E).
Context (E_error : Dcuts_def_error E).

Definition Dcuts_of_Dcuts'_val : hsubtypes Dcuts :=
  λ x : Dcuts, ∃ r : NonnegativeRationals, (¬ (r ∈ x)) × E r.

Lemma Dcuts_of_Dcuts'_bot :
  Π (x : Dcuts),
    Dcuts_of_Dcuts'_val x -> Π y : Dcuts, (y <= x) -> Dcuts_of_Dcuts'_val y.
Proof.
  intros r Xr n Xn.
  revert Xr.
  apply hinhfun.
  intros q.
  exists (pr1 q).
  split.
  intros Nq.
  apply (pr1 (pr2 q)).
  now apply Xn.
  exact (pr2 (pr2 q)).
Qed.

Lemma Dcuts_of_Dcuts'_open :
  Π (x : Dcuts),
    Dcuts_of_Dcuts'_val x ->
    hexists (fun y : Dcuts => dirprod (Dcuts_of_Dcuts'_val y) (x < y)).
Proof.
  intros r.
  apply hinhuniv.
  intros q.
  generalize (E_open _ (pr2 (pr2 q))).
  apply hinhfun.
  intros s.
  exists (NonnegativeRationals_to_Dcuts (pr1 s)).
  split.
  - apply hinhpr.
    exists (pr1 s).
    split.
    + simpl.
      now apply isirrefl_ltNonnegativeRationals.
    + exact (pr1 (pr2 s)).
  - apply hinhpr.
    exists (pr1 q).
    split.
    + exact (pr1 (pr2 q)).
    + simpl.
      exact (pr2 (pr2 s)).
Qed.

Lemma Dcuts_of_Dcuts'_error:
  Π c : Dcuts, 0 < c -> (¬ Dcuts_of_Dcuts'_val c) ∨ (hexists (λ P, Dcuts_of_Dcuts'_val P × ¬ Dcuts_of_Dcuts'_val (Dcuts_plus P c))).
Proof.
  intros C HC.
  assert (∃ c : NonnegativeRationals, c ∈ C × (0 < c)%NRat).
  { revert HC ; apply hinhuniv ; intro d.
    generalize (is_Dcuts_open _ _ (pr2 (pr2 d))).
    apply hinhfun.
    intro c.
    exists (pr1 c).
    split.
    - exact (pr1 (pr2 c)).
    - eapply istrans_le_lt_ltNonnegativeRationals, (pr2 (pr2 c)).
      now apply isnonnegative_NonnegativeRationals. }
  revert X ; apply hinhuniv ; intros c.
  generalize (E_error _ (pr2 (pr2 c))).
  apply hinhfun.
  apply sumofmaps ; [intros Ec | intros q].
  - left.
    unfold neg ; apply hinhuniv'.
    exact isapropempty.
    intros r.
    apply Ec.
    apply E_bot with (1 := (pr2 (pr2 r))).
    apply lt_leNonnegativeRationals, notge_ltNonnegativeRationals.
    intro H.
    apply (pr1 (pr2 r)).
    now apply is_Dcuts_bot with (1 := pr1 (pr2 c)).
  - right.
    apply hinhpr.
    exists (NonnegativeRationals_to_Dcuts (pr1 q)).
    split.
    + apply hinhpr.
      exists (pr1 q).
      split.
      * simpl.
        apply isirrefl_ltNonnegativeRationals.
      * exact (pr1 (pr2 q)).
    + intro H ; apply (pr2 (pr2 q)).
      revert H.
      apply hinhuniv.
      intros r.
      apply E_bot with (1 := (pr2 (pr2 r))).
      apply notlt_geNonnegativeRationals.
      intro H.
      apply (pr1 (pr2 r)).
      generalize (isdecrel_ltNonnegativeRationals (pr1 r) (pr1 c)) ; apply sumofmaps ; intros H0.
      * apply hinhpr.
        left.
        right.
        apply is_Dcuts_bot with (1 := pr1 (pr2 c)).
        now apply lt_leNonnegativeRationals.
      * apply notlt_geNonnegativeRationals in H0.
        apply hinhpr.
        right.
        exists ((pr1 r - pr1 c)%NRat,, pr1 c).
        simpl ; split ; [ | split].
        now apply pathsinv0, minusNonnegativeRationals_plus_r.
        apply_pr2 (plusNonnegativeRationals_ltcompat_r (pr1 c)).
        now rewrite minusNonnegativeRationals_plus_r.
        exact (pr1 (pr2 c)).
Qed.

End Dcuts_of_Dcuts'.

Lemma Dcuts_of_Dcuts_bij :
  Π x : Dcuts, Dcuts_of_Dcuts (Dcuts_of_Dcuts'_val (pr1 x)) (Dcuts_of_Dcuts'_bot (pr1 x)) (Dcuts_of_Dcuts'_error (pr1 x) (is_Dcuts_bot x) (is_Dcuts_error x)) = x.
Proof.
  intros x.
  apply Dcuts_eq_is_eq.
  intros r.
  split.
  - apply hinhuniv.
    intros y.
    generalize (pr1 (pr2 y)).
    apply hinhuniv.
    intros q.
    apply is_Dcuts_bot with (1 := pr2 (pr2 q)).
    apply lt_leNonnegativeRationals, notge_ltNonnegativeRationals.
    intro H.
    apply (pr1 (pr2 q)).
    now apply is_Dcuts_bot with (1 := pr2 (pr2 y)).
  - intros Xr.
    generalize (is_Dcuts_open _ _ Xr).
    apply hinhfun.
    intros q.
    exists (NonnegativeRationals_to_Dcuts (pr1 q)).
    split.
    + apply hinhpr.
      exists (pr1 q).
      split.
      * simpl.
        now apply isirrefl_ltNonnegativeRationals.
      * exact (pr1 (pr2 q)).
    + simpl.
      exact (pr2 (pr2 q)).
Qed.
Lemma Dcuts_of_Dcuts_bij' :
  Π E : hsubtypes Dcuts, Π (E_bot : Π x : Dcuts, E x -> Π y : Dcuts, y <= x -> E y) (E_open : Π x : Dcuts, E x -> ∃ y : Dcuts, x < y × E y),
    Dcuts_of_Dcuts'_val (Dcuts_of_Dcuts_val E) = E.
Proof.
  intros.
  apply funextfun.
  intros x.
  apply hPropUnivalence.
  - apply hinhuniv.
    simpl pr1.
    intros r ; generalize (pr2 (pr2 r)).
    apply hinhuniv.
    intros X.
    apply E_bot with (1 := pr1 (pr2 X)).
    apply Dcuts_lt_le_rel.
    apply hinhpr.
    exists (pr1 r).
    split.
    exact (pr1 (pr2 r)).
    exact (pr2 (pr2 X)).
  - intros Ex.
    generalize (E_open _ Ex).
    apply hinhuniv.
    intros y.
    generalize (pr1 (pr2 y)).
    apply hinhfun.
    intros r.
    exists (pr1 r).
    split.
    exact (pr1 (pr2 r)).
    apply hinhpr.
    exists (pr1 y).
    split.
    apply (pr2 (pr2 y)).
    apply (pr2 (pr2 r)).
Qed.

Lemma isub_Dcuts_of_Dcuts (E : hsubtypes Dcuts) E_bot E_error :
  isUpperBound (X := PreorderedSetEffectiveOrder eo_Dcuts) E (Dcuts_of_Dcuts E E_bot E_error).
Proof.
  intros ;
  intros x Ex r Hr.
  apply hinhpr.
  now exists x.
Qed.
Lemma islbub_Dcuts_of_Dcuts (E : hsubtypes Dcuts) E_bot E_error :
  isSmallerThanUpperBounds (X := PreorderedSetEffectiveOrder eo_Dcuts) E (Dcuts_of_Dcuts E E_bot E_error).
Proof.
  intros.
  intros x Hx ; simpl.
  intros r ; apply hinhuniv ;
  intros y.
  generalize (Hx _ (pr1 (pr2 y))).
  intros H ; apply H.
  exact (pr2 (pr2 y)).
Qed.
Lemma islub_Dcuts_of_Dcuts (E : hsubtypes eo_Dcuts) E_bot E_error :
  isLeastUpperBound (X := PreorderedSetEffectiveOrder eo_Dcuts) E (Dcuts_of_Dcuts E E_bot E_error).
Proof.
  split.
  exact (isub_Dcuts_of_Dcuts E E_bot E_error).
  exact (islbub_Dcuts_of_Dcuts E E_bot E_error).
Qed.



(** * Definition of non-negative real numbers *)

Global Opaque Dcuts.
Global Opaque Dcuts_le_rel
              Dcuts_lt_rel
              Dcuts_ap_rel.
Global Opaque Dcuts_zero
              Dcuts_one
              Dcuts_two
              Dcuts_plus
              Dcuts_minus
              Dcuts_mult
              Dcuts_inv
              Dcuts_max
              Dcuts_min
              Dcuts_half.
Global Opaque Dcuts_lim_cauchy_seq.

Delimit Scope NR_scope with NR.
Open Scope NR_scope.

Definition NonnegativeReals : ConstructiveCommutativeDivisionRig
  := Dcuts_ConstructiveCommutativeDivisionRig.
Definition EffectivelyOrdered_NonnegativeReals : EffectivelyOrderedSet.
Proof.
  exists NonnegativeReals.
  apply (pairEffectiveOrder Dcuts_le_rel Dcuts_lt_rel iseo_Dcuts_le_lt_rel).
Defined.

(** ** Relations *)

Definition apNonnegativeReals : hrel NonnegativeReals := CCDRap.
Definition leNonnegativeReals : po NonnegativeReals := EOle (X := EffectivelyOrdered_NonnegativeReals).
Definition geNonnegativeReals : po NonnegativeReals := EOge (X := EffectivelyOrdered_NonnegativeReals).
Definition ltNonnegativeReals : StrongOrder NonnegativeReals := EOlt (X := EffectivelyOrdered_NonnegativeReals).
Definition gtNonnegativeReals : StrongOrder NonnegativeReals := EOgt (X := EffectivelyOrdered_NonnegativeReals).

Notation "x ≠ y" := (apNonnegativeReals x y) (at level 70, no associativity) : NR_scope.
Notation "x <= y" := (EOle_rel (X := EffectivelyOrdered_NonnegativeReals) x y) : NR_scope.
Notation "x >= y" := (EOge_rel (X := EffectivelyOrdered_NonnegativeReals) x y) : NR_scope.
Notation "x < y" := (EOlt_rel (X := EffectivelyOrdered_NonnegativeReals) x y) : NR_scope.
Notation "x > y" := (EOgt_rel (X := EffectivelyOrdered_NonnegativeReals) eo_Dcuts x y) : NR_scope.

(** ** Constants and Functions *)

Definition zeroNonnegativeReals : NonnegativeReals := CCDRzero.
Definition oneNonnegativeReals : NonnegativeReals := CCDRone.
Definition twoNonnegativeReals : NonnegativeReals := Dcuts_two.
Definition plusNonnegativeReals : binop NonnegativeReals := CCDRplus.
Definition multNonnegativeReals : binop NonnegativeReals := CCDRmult.

Definition NonnegativeRationals_to_NonnegativeReals (r : NonnegativeRationals) : NonnegativeReals :=
  NonnegativeRationals_to_Dcuts r.
Definition nat_to_NonnegativeReals (n : nat) : NonnegativeReals :=
  NonnegativeRationals_to_NonnegativeReals (nat_to_NonnegativeRationals n).

Notation "0" := zeroNonnegativeReals : NR_scope.
Notation "1" := oneNonnegativeReals : NR_scope.
Notation "2" := twoNonnegativeReals : NR_scope.
Notation "x + y" := (plusNonnegativeReals x y) (at level 50, left associativity) : NR_scope.
Notation "x * y" := (multNonnegativeReals x y) (at level 40, left associativity) : NR_scope.

Definition invNonnegativeReals (x : NonnegativeReals) (Hx0 : x ≠ 0) : NonnegativeReals :=
  CCDRinv x Hx0.
Definition divNonnegativeReals (x y : NonnegativeReals) (Hy0 : y ≠ 0) : NonnegativeReals :=
  x * (invNonnegativeReals y Hy0).

(** ** Special functions *)

Definition NonnegativeReals_to_hsubtypesNonnegativeRationals :
  NonnegativeReals → (hsubtypes NonnegativeRationals) := pr1.
Definition hsubtypesNonnegativeRationals_to_NonnegativeReals
  (X : NonnegativeRationals -> hProp)
  (Xbot : Π x : NonnegativeRationals,
            X x -> Π y : NonnegativeRationals, (y <= x)%NRat -> X y)
  (Xopen : Π x : NonnegativeRationals,
             X x ->
             hexists (fun y : NonnegativeRationals => dirprod (X y) (x < y)%NRat))
  (Xtop : Dcuts_def_error X) : NonnegativeReals :=
  mk_Dcuts X Xbot Xopen Xtop.

Definition minusNonnegativeReals : binop NonnegativeReals := Dcuts_minus.
Definition halfNonnegativeReals : unop NonnegativeReals := Dcuts_half.
Definition maxNonnegativeReals : binop NonnegativeReals := Dcuts_max.
Definition minNonnegativeReals : binop NonnegativeReals := Dcuts_min.

Notation "x - y" := (minusNonnegativeReals x y) (at level 50, left associativity) : NR_scope.
Notation "x / 2" := (halfNonnegativeReals x) (at level 35, no associativity) : NR_scope.

(** ** Theorems *)

(** ** Compatibility with NonnegativeRationals *)

Lemma NonnegativeRationals_to_NonnegativeReals_lt :
  Π x y : NonnegativeRationals,
    (x < y)%NRat <->
    NonnegativeRationals_to_NonnegativeReals x < NonnegativeRationals_to_NonnegativeReals y.
Proof.
  intros x y ; split.
  - intros Hxy.
    apply hinhpr.
    exists x.
    split ; simpl.
    + now apply isirrefl_ltNonnegativeRationals.
    + exact Hxy.
  - apply hinhuniv ; simpl ; intros q.
    eapply istrans_le_lt_ltNonnegativeRationals, (pr2 (pr2 q)).
    apply notlt_geNonnegativeRationals.
    exact (pr1 (pr2 q)).
Qed.

Lemma NonnegativeRationals_to_NonnegativeReals_le :
  Π x y : NonnegativeRationals,
    (x <= y)%NRat <->
    NonnegativeRationals_to_NonnegativeReals x <= NonnegativeRationals_to_NonnegativeReals y.
Proof.
  intros x y ; split.
  - intros H.
    apply Dcuts_nlt_ge.
    intro H0.
    revert H.
    apply_pr2 notge_ltNonnegativeRationals.
    apply_pr2 NonnegativeRationals_to_NonnegativeReals_lt.
    exact H0.
  - intros H.
    apply notlt_geNonnegativeRationals.
    intros H0.
    revert H.
    apply Dcuts_gt_nle.
    apply NonnegativeRationals_to_NonnegativeReals_lt.
    exact H0.
Qed.

Lemma NonnegativeRationals_to_NonnegativeReals_zero :
  NonnegativeRationals_to_NonnegativeReals 0%NRat = 0.
Proof.
  reflexivity.
Qed.
Lemma NonnegativeRationals_to_NonnegativeReals_one :
  NonnegativeRationals_to_NonnegativeReals 1%NRat = 1.
Proof.
  reflexivity.
Qed.
Lemma NonnegativeRationals_to_NonnegativeReals_plus :
  Π x y : NonnegativeRationals, NonnegativeRationals_to_NonnegativeReals (x + y)%NRat = NonnegativeRationals_to_NonnegativeReals x + NonnegativeRationals_to_NonnegativeReals y.
Proof.
  intros x y.
  apply Dcuts_eq_is_eq.
  intros r.
  split.
  - intros Hr.
    generalize (eq0orgt0NonnegativeRationals y) ; apply sumofmaps ; intros Hy.
    2: generalize (eq0orgt0NonnegativeRationals x) ; apply sumofmaps ; intros Hx.
    + rewrite Hy in Hr |- * ; clear y Hy.
      rewrite isrunit_zeroNonnegativeRationals in Hr.
      rewrite isrunit_Dcuts_plus_zero.
      exact Hr.
    + rewrite Hx in Hr |- * ; clear x Hx.
      rewrite islunit_zeroNonnegativeRationals in Hr.
      rewrite islunit_Dcuts_plus_zero.
      exact Hr.
    + assert (Hxy : (0 < x + y)%NRat).
      { apply ispositive_plusNonnegativeRationals_r.
        exact Hy. }
      apply hinhpr ; right.
      exists ((r * (x / (x + y)))%NRat,,(r * (y / (x + y)))%NRat).
      simpl.
      split ; [ | split].
      * unfold divNonnegativeRationals.
        rewrite <- isldistr_mult_plusNonnegativeRationals, <- isrdistr_mult_plusNonnegativeRationals, isrinv_NonnegativeRationals, isrunit_oneNonnegativeRationals.
        reflexivity.
        exact Hxy.
      * unfold divNonnegativeRationals.
        rewrite <- isassoc_multNonnegativeRationals, (iscomm_multNonnegativeRationals _ x), isassoc_multNonnegativeRationals.
        pattern x at 3 ;
          rewrite <- (isrunit_oneNonnegativeRationals x).
        apply multNonnegativeRationals_ltcompat_l.
        exact Hx.
        rewrite <- (isrinv_NonnegativeRationals (x + y)%NRat).
        apply multNonnegativeRationals_ltcompat_r.
        apply ispositive_invNonnegativeRationals.
        exact Hxy.
        exact Hr.
        exact Hxy.
      * unfold divNonnegativeRationals.
        rewrite <- isassoc_multNonnegativeRationals, (iscomm_multNonnegativeRationals _ y), isassoc_multNonnegativeRationals.
        pattern y at 3 ;
          rewrite <- (isrunit_oneNonnegativeRationals y).
        apply multNonnegativeRationals_ltcompat_l.
        exact Hy.
        rewrite <- (isrinv_NonnegativeRationals (x + y)%NRat).
        apply multNonnegativeRationals_ltcompat_r.
        apply ispositive_invNonnegativeRationals.
        exact Hxy.
        exact Hr.
        exact Hxy.
  - apply hinhuniv ; apply sumofmaps ; [ apply sumofmaps ; [intros Hrx | intros Hry] | intros xy ; rewrite (pr1 (pr2 xy))] ; simpl.
    + eapply istrans_lt_le_ltNonnegativeRationals, plusNonnegativeRationals_le_r.
      exact Hrx.
    + eapply istrans_lt_le_ltNonnegativeRationals, plusNonnegativeRationals_le_l.
      exact Hry.
    + apply plusNonnegativeRationals_ltcompat.
      exact (pr1 (pr2 (pr2 xy))).
      exact (pr2 (pr2 (pr2 xy))).
Qed.

Lemma NonnegativeRationals_to_NonnegativeReals_minus :
  Π x y : NonnegativeRationals, NonnegativeRationals_to_NonnegativeReals (x - y)%NRat = NonnegativeRationals_to_NonnegativeReals x - NonnegativeRationals_to_NonnegativeReals y.
Proof.
  intros x y.
  generalize (isdecrel_leNonnegativeRationals x y) ; apply sumofmaps ; intros Hxy.
  - rewrite minusNonnegativeRationals_eq_zero, Dcuts_minus_eq_zero.
    reflexivity.
    apply NonnegativeRationals_to_NonnegativeReals_le.
    exact Hxy.
    exact Hxy.
  - apply Dcuts_minus_correct_r.
    rewrite <- NonnegativeRationals_to_NonnegativeReals_plus, minusNonnegativeRationals_plus_r.
    reflexivity.
    apply lt_leNonnegativeRationals.
    apply notge_ltNonnegativeRationals.
    exact Hxy.
Qed.
Lemma NonnegativeRationals_to_NonnegativeReals_mult :
  Π x y : NonnegativeRationals, NonnegativeRationals_to_NonnegativeReals (x * y)%NRat = NonnegativeRationals_to_NonnegativeReals x * NonnegativeRationals_to_NonnegativeReals y.
Proof.
  intros x y.
  generalize (eq0orgt0NonnegativeRationals x) ; apply sumofmaps ; [intros -> | intros Hx].
  - rewrite islabsorb_zero_multNonnegativeRationals, islabsorb_Dcuts_mult_zero.
    reflexivity.
  - rewrite <- (Dcuts_NQmult_mult _ _ Hx).
    apply Dcuts_eq_is_eq.
    intros r.
    split.
    + simpl ; intros Hr ; apply hinhpr.
      exists (r / x)%NRat.
      split.
      * apply pathsinv0, multdivNonnegativeRationals.
        exact Hx.
      * rewrite <- (isrunit_oneNonnegativeRationals y), <- (isrinv_NonnegativeRationals x), <- isassoc_multNonnegativeRationals.
        apply multNonnegativeRationals_ltcompat_r.
        apply ispositive_invNonnegativeRationals.
        exact Hx.
        rewrite iscomm_multNonnegativeRationals.
        exact Hr.
        exact Hx.
    + apply hinhuniv.
      simpl.
      intros ry.
      rewrite (pr1 (pr2 ry)).
      apply multNonnegativeRationals_ltcompat_l.
      exact Hx.
      exact (pr2 (pr2 ry)).
Qed.

Lemma NonnegativeRationals_to_NonnegativeReals_nattorig :
  Π n : nat, NonnegativeRationals_to_NonnegativeReals (nattorig n) = nattorig n.
Proof.
  induction n.
  - reflexivity.
  - rewrite !nattorigS.
    rewrite NonnegativeRationals_to_NonnegativeReals_plus, IHn.
    reflexivity.
Qed.

Lemma nat_to_NonnegativeReals_O :
  nat_to_NonnegativeReals O = 0.
Proof.
  unfold nat_to_NonnegativeReals.
  rewrite nat_to_NonnegativeRationals_O.
  reflexivity.
Qed.
Lemma nat_to_NonnegativeReals_Sn :
  Π n : nat, nat_to_NonnegativeReals (S n) = nat_to_NonnegativeReals n + 1.
Proof.
  intros n.
  unfold nat_to_NonnegativeReals.
  rewrite nat_to_NonnegativeRationals_Sn.
  rewrite NonnegativeRationals_to_NonnegativeReals_plus.
  reflexivity.
Qed.

(** Order, apartness, and equality *)

Definition istrans_leNonnegativeReals :
  Π x y z : NonnegativeReals, x <= y -> y <= z -> x <= z
  := istrans_EOle (X := EffectivelyOrdered_NonnegativeReals).
Definition isrefl_leNonnegativeReals :
  Π x : NonnegativeReals, x <= x
  := isrefl_EOle (X := EffectivelyOrdered_NonnegativeReals).
Lemma isantisymm_leNonnegativeReals :
  Π x y : NonnegativeReals, x <= y × y <= x <-> x = y.
Proof.
  intros x y ; split.
  - intros H.
    apply Dcuts_le_ge_eq.
    now apply (pr1 H).
    now apply (pr2 H).
  -  intros ->.
     split ; apply isrefl_leNonnegativeReals.
Qed.
Lemma eqNonnegativeReals_le :
  Π x y : NonnegativeReals, x = y -> x <= y.
Proof.
  intros x y ->.
  apply isrefl_leNonnegativeReals.
Qed.

Definition istrans_ltNonnegativeReals :
  Π x y z : NonnegativeReals, x < y -> y < z -> x < z
  := istrans_EOlt (X := EffectivelyOrdered_NonnegativeReals).
Definition iscotrans_ltNonnegativeReals :
  Π x y z : NonnegativeReals, x < z -> x < y ∨ y < z
  := iscotrans_Dcuts_lt_rel.
Definition isirrefl_ltNonnegativeReals :
  Π x : NonnegativeReals, ¬ (x < x)
  := isirrefl_EOlt (X := EffectivelyOrdered_NonnegativeReals).

Definition istrans_lt_le_ltNonnegativeReals :
  Π x y z : NonnegativeReals, x < y -> y <= z -> x < z
  := istrans_EOlt_le (X := EffectivelyOrdered_NonnegativeReals).
Definition istrans_le_lt_ltNonnegativeReals :
  Π x y z : NonnegativeReals, x <= y -> y < z -> x < z
  := istrans_EOle_lt (X := EffectivelyOrdered_NonnegativeReals).

Lemma lt_leNonnegativeReals :
  Π x y : NonnegativeReals, x < y -> x <= y.
Proof.
  exact Dcuts_lt_le_rel.
Qed.
Lemma notlt_leNonnegativeReals :
  Π x y : NonnegativeReals, ¬ (x < y) <-> (y <= x).
Proof.
  exact Dcuts_nlt_ge.
Qed.

Lemma isnonnegative_NonnegativeReals :
  Π x : NonnegativeReals, 0 <= x.
Proof.
  intros x.
  now apply Dcuts_ge_0.
Qed.
Lemma isnonnegative_NonnegativeReals' :
  Π x : NonnegativeReals, ¬ (x < 0).
Proof.
  intros x.
  now apply Dcuts_notlt_0.
Qed.
Lemma le0_NonnegativeReals :
  Π x : NonnegativeReals, (x <= 0) <-> (x = 0).
Proof.
  intros x ; split ; intros Hx.
  apply isantisymm_leNonnegativeReals.
  - split.
    exact Hx.
    apply isnonnegative_NonnegativeReals.
  - rewrite Hx.
    apply isrefl_leNonnegativeReals.
Qed.

Lemma ap_ltNonnegativeReals :
  Π x y : NonnegativeReals, x ≠ y <-> (x < y) ⨿  (y < x).
Proof.
  now intros x y ; split.
Qed.
Definition isirrefl_apNonnegativeReals :
  Π x : NonnegativeReals, ¬ (x ≠ x)
  := isirrefl_Dcuts_ap_rel.
Definition issymm_apNonnegativeReals :
  Π x y : NonnegativeReals, x ≠ y -> y ≠ x
  := issymm_Dcuts_ap_rel.
Definition iscotrans_apNonnegativeReals :
  Π x y z : NonnegativeReals, x ≠ z -> x ≠ y ∨ y ≠ z
  := iscotrans_Dcuts_ap_rel.
Lemma istight_apNonnegativeReals:
  Π x y : NonnegativeReals, (¬ (x ≠ y)) <-> (x = y).
Proof.
  intros x y.
  split.
  - now apply istight_Dcuts_ap_rel.
  - intros ->.
    now apply isirrefl_Dcuts_ap_rel.
Qed.

Lemma ispositive_apNonnegativeReals :
  Π x : NonnegativeReals, x ≠ 0 <-> 0 < x.
Proof.
  intros X ; split.
  - apply sumofmaps ; [ | intros Hlt ].
    apply hinhuniv ; intros x.
    apply fromempty.
    now apply (Dcuts_zero_empty _ (pr2 (pr2 x))).
    exact Hlt.
  - intros Hx.
    now right.
Qed.

Definition isnonzeroNonnegativeReals: 1 ≠ 0
  := isnonzeroCCDR (X := NonnegativeReals).

Lemma ispositive_oneNonnegativeReals: 0 < 1.
Proof.
  apply ispositive_apNonnegativeReals.
  exact isnonzeroNonnegativeReals.
Qed.

(** addition *)

Definition ap_plusNonnegativeReals:
  Π x x' y y' : NonnegativeReals,
    x + y ≠ x' + y' -> x ≠ x' ∨ y ≠ y'
  := apCCDRplus (X := NonnegativeReals).

Definition islunit_zero_plusNonnegativeReals:
  Π x : NonnegativeReals, 0 + x = x
  := islunit_CCDRzero_CCDRplus (X := NonnegativeReals).
Definition isrunit_zero_plusNonnegativeReals:
  Π x : NonnegativeReals, x + 0 = x
  := isrunit_CCDRzero_CCDRplus (X := NonnegativeReals).
Definition isassoc_plusNonnegativeReals:
  Π x y z : NonnegativeReals, x + y + z = x + (y + z)
  := isassoc_CCDRplus (X := NonnegativeReals).
Definition iscomm_plusNonnegativeReals:
  Π x y : NonnegativeReals, x + y = y + x
  := iscomm_CCDRplus (X := NonnegativeReals).

Definition plusNonnegativeReals_ltcompat_l :
  Π x y z: NonnegativeReals, (y < z) <-> (y + x < z + x)
  := Dcuts_plus_ltcompat_l.
Definition plusNonnegativeReals_ltcompat_r :
  Π x y z: NonnegativeReals, (y < z) <-> (x + y < x + z)
  := Dcuts_plus_ltcompat_r.

Lemma plusNonnegativeReals_ltcompat :
  Π x y z t : NonnegativeReals, x < y -> z < t -> x + z < y + t.
Proof.
  intros x y z t Hxy Hzt.
  eapply istrans_ltNonnegativeReals, plusNonnegativeReals_ltcompat_l.
  now apply plusNonnegativeReals_ltcompat_r.
  exact Hxy.
Qed.
Lemma plusNonnegativeReals_lt_l:
  Π x y : NonnegativeReals, 0 < x <-> y < x + y.
Proof.
  intros x y.
  pattern y at 1.
  rewrite <- (islunit_zero_plusNonnegativeReals y).
  now apply plusNonnegativeReals_ltcompat_l.
Qed.
Lemma plusNonnegativeReals_lt_r:
  Π x y : NonnegativeReals, 0 < y <-> x < x + y.
Proof.
  intros x y.
  pattern x at 1.
  rewrite <- (isrunit_zero_plusNonnegativeReals x).
  now apply plusNonnegativeReals_ltcompat_r.
Qed.

Definition plusNonnegativeReals_lecompat_l :
  Π x y z: NonnegativeReals, (y <= z) <-> (y + x <= z + x)
  := Dcuts_plus_lecompat_l.
Definition plusNonnegativeReals_lecompat_r :
  Π x y z: NonnegativeReals, (y <= z) <-> (x + y <= x + z)
  := Dcuts_plus_lecompat_r.
Lemma plusNonnegativeReals_lecompat :
  Π x y x' y' : NonnegativeReals,
    x <= y -> x' <= y' -> x + x' <= y + y'.
Proof.
  intros x y x' y' H H'.
  refine (istrans_leNonnegativeReals _ _ _ _ _).
  apply plusNonnegativeReals_lecompat_l.
  apply H.
  apply plusNonnegativeReals_lecompat_r.
  exact H'.
Qed.

Lemma plusNonnegativeReals_le_l :
  Π (x y : NonnegativeReals), x <= x + y.
Proof.
  exact Dcuts_plus_le_l.
Qed.
Lemma plusNonnegativeReals_le_r :
  Π (x y : NonnegativeReals), y <= x + y.
Proof.
  exact Dcuts_plus_le_r.
Qed.

Lemma plusNonnegativeReals_le_ltcompat :
  Π x y z t : NonnegativeReals,
    x <= y -> z < t -> x + z < y + t.
Proof.
  intros x y z t Hxy Hzt.
  eapply istrans_le_lt_ltNonnegativeReals, plusNonnegativeReals_ltcompat_r, Hzt.
  now apply plusNonnegativeReals_lecompat_l.
Qed.

Lemma plusNonnegativeReals_eqcompat_l :
  Π x y z: NonnegativeReals, (y + x = z + x) <-> (y = z).
Proof.
  intros x y z ; split.
  - intro H ;
    apply isantisymm_leNonnegativeReals ; split.
    + apply_pr2 (plusNonnegativeReals_lecompat_l x).
      rewrite H ; refine (isrefl_leNonnegativeReals _).
    + apply_pr2 (plusNonnegativeReals_lecompat_l x).
      rewrite H ; refine (isrefl_leNonnegativeReals _).
  - now intros ->.
Qed.
Lemma plusNonnegativeReals_eqcompat_r :
  Π x y z: NonnegativeReals, (x + y = x + z) <-> (y = z).
Proof.
  intros x y z.
  rewrite ! (iscomm_plusNonnegativeReals x).
  now apply plusNonnegativeReals_eqcompat_l.
Qed.

Lemma plusNonnegativeReals_apcompat_l :
  Π x y z: NonnegativeReals, (y ≠ z) <-> (y + x ≠ z + x).
Proof.
  intros a b c.
  split.
  - intro H.
    apply ap_ltNonnegativeReals.
    apply_pr2_in ap_ltNonnegativeReals H.
    destruct H as [H | H].
    + left ;
      now apply plusNonnegativeReals_ltcompat_l.
    + right ;
      now apply plusNonnegativeReals_ltcompat_l.
  - now apply islapbinop_Dcuts_plus.
Qed.
Lemma plusNonnegativeReals_apcompat_r :
  Π x y z: NonnegativeReals, (y ≠ z) <-> (x + y ≠ x + z).
Proof.
  intros x y z.
  rewrite ! (iscomm_plusNonnegativeReals x).
  now apply plusNonnegativeReals_apcompat_l.
Qed.

(** Subtraction *)

Definition minusNonnegativeReals_plus_r :
  Π x y z : NonnegativeReals, z <= y -> x = y - z -> y = x + z
  := Dcuts_minus_plus_r.
Definition minusNonnegativeReals_eq_zero :
  Π x y : NonnegativeReals, x <= y -> x - y = 0
  := Dcuts_minus_eq_zero.
Definition minusNonnegativeReals_correct_r :
  Π x y z : NonnegativeReals, x = y + z -> y = x - z
  := Dcuts_minus_correct_r.
Definition minusNonnegativeReals_correct_l :
  Π x y z : NonnegativeReals, x = y + z -> z = x - y
  := Dcuts_minus_correct_l.
Definition ispositive_minusNonnegativeReals :
  Π x y : NonnegativeReals, (y < x) <-> (0 < x - y)
  := ispositive_Dcuts_minus.
Definition minusNonnegativeReals_le :
  Π x y : NonnegativeReals, x - y <= x
  := Dcuts_minus_le.

(** Multiplication *)

Definition ap_multNonnegativeReals:
  Π x x' y y' : NonnegativeReals,
    x * y ≠ x' * y' -> x ≠ x' ∨ y ≠ y'
  := apCCDRmult (X := NonnegativeReals).

Definition islunit_one_multNonnegativeReals:
  Π x : NonnegativeReals, 1 * x = x
  := islunit_CCDRone_CCDRmult (X := NonnegativeReals).
Definition isrunit_one_multNonnegativeReals:
  Π x : NonnegativeReals, x * 1 = x
  := isrunit_CCDRone_CCDRmult (X := NonnegativeReals).
Definition isassoc_multNonnegativeReals:
  Π x y z : NonnegativeReals, x * y * z = x * (y * z)
  := isassoc_CCDRmult (X := NonnegativeReals).
Definition iscomm_multNonnegativeReals:
  Π x y : NonnegativeReals, x * y = y * x
  := iscomm_CCDRmult (X := NonnegativeReals).
Definition islabsorb_zero_multNonnegativeReals:
  Π x : NonnegativeReals, 0 * x = 0
  := islabsorb_CCDRzero_CCDRmult (X := NonnegativeReals).
Definition israbsorb_zero_multNonnegativeReals:
  Π x : NonnegativeReals, x * 0 = 0
  := israbsorb_CCDRzero_CCDRmult (X := NonnegativeReals).

Definition multNonnegativeReals_ltcompat_l :
  Π x y z: NonnegativeReals, (0 < x) -> (y < z) -> (y * x < z * x)
  := Dcuts_mult_ltcompat_l.
Definition multNonnegativeReals_ltcompat_l' :
  Π x y z: NonnegativeReals, (y * x < z * x) -> (y < z)
  := Dcuts_mult_ltcompat_l'.
Definition multNonnegativeReals_lecompat_l :
  Π x y z: NonnegativeReals, (0 < x) -> (y * x <= z * x) -> (y <= z)
  := Dcuts_mult_lecompat_l.
Definition multNonnegativeReals_lecompat_l' :
  Π x y z: NonnegativeReals, (y <= z) -> (y * x <= z * x)
  := Dcuts_mult_lecompat_l'.

Definition multNonnegativeReals_ltcompat_r :
  Π x y z: NonnegativeReals, (0 < x) -> (y < z) -> (x * y < x * z)
  := Dcuts_mult_ltcompat_r.
Definition multNonnegativeReals_ltcompat_r' :
  Π x y z: NonnegativeReals, (x * y < x *  z) -> (y < z)
  := Dcuts_mult_ltcompat_r'.
Definition multNonnegativeReals_lecompat_r :
  Π x y z: NonnegativeReals, (0 < x) -> (x * y <= x * z) -> (y <= z)
  := Dcuts_mult_lecompat_r.
Definition multNonnegativeReals_lecompat_r' :
  Π x y z: NonnegativeReals, (y <= z) -> (x * y <= x * z)
  := Dcuts_mult_lecompat_r'.

(** Multiplicative Inverse *)

Definition islinv_invNonnegativeReals:
  Π (x : NonnegativeReals) (Hx0 : x ≠ 0), invNonnegativeReals x Hx0 * x = 1
  := islinv_CCDRinv (X := NonnegativeReals).
Definition isrinv_invNonnegativeReals:
  Π (x : NonnegativeReals) (Hx0 : x ≠ 0), x * invNonnegativeReals x Hx0 = 1
  := isrinv_CCDRinv (X := NonnegativeReals).

Definition isldistr_plus_multNonnegativeReals:
  Π x y z : NonnegativeReals, z * (x + y) = z * x + z * y
  := isldistr_CCDRplus_CCDRmult (X := NonnegativeReals).
Definition isrdistr_plus_multNonnegativeReals:
  Π x y z : NonnegativeReals, (x + y) * z = x * z + y * z
  := isrdistr_CCDRplus_CCDRmult (X := NonnegativeReals).

(** maximum *)

Lemma iscomm_maxNonnegativeReals :
  Π x y : NonnegativeReals,
    maxNonnegativeReals x y = maxNonnegativeReals y x.
Proof.
  exact iscomm_Dcuts_max.
Qed.
Lemma isassoc_maxNonnegativeReals :
  Π x y z : NonnegativeReals,
    maxNonnegativeReals (maxNonnegativeReals x y) z =
    maxNonnegativeReals x (maxNonnegativeReals y z).
Proof.
  exact isassoc_Dcuts_max.
Qed.

Lemma isldistr_max_plusNonnegativeReals :
  Π x y z : NonnegativeReals,
    z + maxNonnegativeReals x y = maxNonnegativeReals (z + x) (z + y).
Proof.
  exact isldistr_Dcuts_max_plus.
Qed.
Lemma isrdistr_max_plusNonnegativeReals :
  Π x y z : NonnegativeReals,
    maxNonnegativeReals x y + z = maxNonnegativeReals (x + z) (y + z).
Proof.
  intros x y z.
  rewrite !(iscomm_plusNonnegativeReals _ z).
  now apply isldistr_max_plusNonnegativeReals.
Qed.

Lemma isldistr_max_multNonnegativeReals :
  Π x y z : NonnegativeReals,
    z * maxNonnegativeReals x y = maxNonnegativeReals (z * x) (z * y).
Proof.
  exact isldistr_Dcuts_max_mult.
Qed.
Lemma isrdistr_max_multNonnegativeReals :
  Π x y z : NonnegativeReals,
    maxNonnegativeReals x y * z = maxNonnegativeReals (x * z) (y * z).
Proof.
  intros x y z.
  rewrite !(iscomm_multNonnegativeReals _ z).
  now apply isldistr_max_multNonnegativeReals.
Qed.

Lemma maxNonnegativeReals_carac_l :
  Π x y : NonnegativeReals,
    y <= x -> maxNonnegativeReals x y = x.
Proof.
  exact Dcuts_max_carac_l.
Qed.
Lemma maxNonnegativeReals_carac_r :
  Π x y : NonnegativeReals,
    x <= y -> maxNonnegativeReals x y = y.
Proof.
  exact Dcuts_max_carac_r.
Qed.

Lemma maxNonnegativeReals_le_l :
  Π x y : NonnegativeReals,
    x <= maxNonnegativeReals x y.
Proof.
  exact Dcuts_max_le_l.
Qed.
Lemma maxNonnegativeReals_le_r :
  Π x y : NonnegativeReals,
    y <= maxNonnegativeReals x y.
Proof.
  exact Dcuts_max_le_r.
Qed.

Lemma maxNonnegativeReals_lt :
  Π x y z : NonnegativeReals,
    x < z -> y < z
    -> maxNonnegativeReals x y < z.
Proof.
  exact Dcuts_max_lt.
Qed.
Lemma maxNonnegativeReals_le :
  Π x y z : NonnegativeReals,
    x <= z -> y <= z
    -> maxNonnegativeReals x y <= z.
Proof.
  exact Dcuts_max_le.
Qed.

Lemma maxNonnegativeReals_minus_plus:
  Π x y : NonnegativeReals,
    maxNonnegativeReals x y = (x - y) + y.
Proof.
  intros x y.
  apply pathsinv0.
  now apply Dcuts_minus_plus_max.
Qed.

Lemma isldistr_minus_multNonnegativeReals :
  Π x y z : NonnegativeReals, z * (x - y) = z * x - z * y.
Proof.
  intros x y z.
  apply plusNonnegativeReals_eqcompat_l with (Dcuts_mult z y).
  rewrite <- isldistr_plus_multNonnegativeReals, <- !maxNonnegativeReals_minus_plus.
  apply isldistr_max_multNonnegativeReals.
Qed.
Lemma isrdistr_minus_multNonnegativeReals :
   Π x y z : NonnegativeReals, (x - y) * z = x * z - y * z.
Proof.
  intros x y z.
  rewrite !(iscomm_multNonnegativeReals _ z).
  now apply isldistr_minus_multNonnegativeReals.
Qed.

Lemma isassoc_minusNonnegativeReals :
  Π x y z : NonnegativeReals,
    (x - y) - z = x - (y + z).
Proof.
  intros x y z.
  apply plusNonnegativeReals_eqcompat_l with (y + z).
  rewrite <- maxNonnegativeReals_minus_plus.
  rewrite (iscomm_plusNonnegativeReals y).
  rewrite <- isassoc_plusNonnegativeReals.
  rewrite <- maxNonnegativeReals_minus_plus.
  rewrite isrdistr_max_plusNonnegativeReals.
  rewrite <- maxNonnegativeReals_minus_plus.
  rewrite isassoc_maxNonnegativeReals.
  apply maponpaths.
  apply maxNonnegativeReals_carac_r.
  now apply plusNonnegativeReals_le_r.
Qed.
Lemma iscomm_minusNonnegativeReals :
  Π x y z : NonnegativeReals,
    x - y - z = x - z - y.
Proof.
  intros x y z.
  rewrite !isassoc_minusNonnegativeReals.
  apply maponpaths.
  now apply iscomm_plusNonnegativeReals.
Qed.

Lemma max_plusNonnegativeReals :
  Π x y : NonnegativeReals,
    (0 < x -> y = 0) ->
    maxNonnegativeReals x y = x + y.
Proof.
  exact Dcuts_max_plus.
Qed.

(** half of a non-negative real numbers *)

Lemma double_halfNonnegativeReals :
  Π x : NonnegativeReals, x = (x / 2) + (x / 2).
Proof.
  exact Dcuts_half_double.
Qed.
Lemma isdistr_plus_halfNonnegativeReals:
  Π x y : NonnegativeReals,
    (x + y) / 2 = (x / 2) + (y / 2).
Proof.
  exact isdistr_Dcuts_half_plus.
Qed.
Lemma ispositive_halfNonnegativeReals:
  Π x : NonnegativeReals,
    (0 < x) <-> (0 < x / 2).
Proof.
  exact ispositive_Dcuts_half.
Qed.

(** ** NonnegativeRationals is dense in NonnegativeReals *)

Lemma NonnegativeReals_dense :
  Π x y : NonnegativeReals, x < y -> ∃ r : NonnegativeRationals, x < NonnegativeRationals_to_NonnegativeReals r × NonnegativeRationals_to_NonnegativeReals r < y.
Proof.
  intros x y.
  apply hinhuniv ; intros q.
  generalize (is_Dcuts_open y (pr1 q) (pr2 (pr2 q))).
  apply hinhfun ; intros r.
  exists (pr1 r) ; split ; apply hinhpr.
  - exists (pr1 q) ; split.
    + exact (pr1 (pr2 q)).
    + exact (pr2 (pr2 r)).
  - exists (pr1 r) ; split.
    + exact (isirrefl_ltNonnegativeRationals _).
    + exact (pr1 (pr2 r)).
Qed.

(** ** Archimedean property *)

Lemma NonnegativeReals_Archimedean :
  isarchrig gtNonnegativeReals.
Proof.
  set (H := isarchNonnegativeRationals).
  repeat split.
  - intros y1 y2 Hy.
    generalize (NonnegativeReals_dense _ _ Hy).
    apply hinhuniv ; clear Hy.
    intros r2.
    generalize (NonnegativeReals_dense _ _ (pr2 (pr2 r2))).
    apply hinhuniv.
    intros r1.
    generalize (isarchrig_1 _ H _ _ (pr2 (NonnegativeRationals_to_NonnegativeReals_lt (pr1 r2) (pr1 r1)) (pr1 (pr2 r1)))).
    apply hinhfun.
    intros n.
    exists (pr1 n).
    eapply istrans_le_lt_ltNonnegativeReals, istrans_lt_le_ltNonnegativeReals.
    2: apply NonnegativeRationals_to_NonnegativeReals_lt, (pr2 n).
    rewrite NonnegativeRationals_to_NonnegativeReals_plus, NonnegativeRationals_to_NonnegativeReals_mult,  NonnegativeRationals_to_NonnegativeReals_nattorig.
    apply plusNonnegativeReals_lecompat_r, multNonnegativeReals_lecompat_r'.
    apply lt_leNonnegativeReals, (pr1 (pr2 r2)).
    rewrite NonnegativeRationals_to_NonnegativeReals_mult, NonnegativeRationals_to_NonnegativeReals_nattorig.
    apply multNonnegativeReals_lecompat_r'.
    apply lt_leNonnegativeReals, (pr2 (pr2 r1)).
  - intros x.
    generalize (Dcuts_def_error_finite _ (is_Dcuts_error x)).
    apply hinhuniv ; intros r.
    generalize (isarchrig_2 _ H (pr1 r)).
    apply hinhfun.
    intros n.
    exists (pr1 n).
    apply istrans_le_lt_ltNonnegativeReals with (NonnegativeRationals_to_NonnegativeReals (pr1 r)).
    apply NonnegativeRationals_to_Dcuts_notin_le.
    exact (pr2 r).
    rewrite <- NonnegativeRationals_to_NonnegativeReals_nattorig.
    apply NonnegativeRationals_to_NonnegativeReals_lt.
    exact (pr2 n).
  - intros x.
    apply hinhpr.
    exists 1%nat.
    apply istrans_lt_le_ltNonnegativeReals with 1.
    apply ispositive_oneNonnegativeReals.
    apply plusNonnegativeReals_le_l.
Qed.

(** ** Completeness *)

Definition Cauchy_seq (u : nat -> NonnegativeReals) : hProp
  := hProppair (Π eps : NonnegativeReals,
                   0 < eps ->
                   hexists
                     (λ N : nat,
                            Π n m : nat, N ≤ n -> N ≤ m -> u n < u m + eps × u m < u n + eps))
               (impred_isaprop _ (λ _, isapropimpl _ _ (pr2 _))).
Definition is_lim_seq (u : nat -> NonnegativeReals) (l : NonnegativeReals) : hProp
  := hProppair (Π eps : NonnegativeReals,
                   0 < eps ->
                   hexists
                     (λ N : nat,
                            Π n : nat, N ≤ n -> u n < l + eps × l < u n + eps))
               (impred_isaprop _ (λ _, isapropimpl _ _ (pr2 _))).

Definition Cauchy_lim_seq (u : nat → NonnegativeReals) (Cu : Cauchy_seq u) : NonnegativeReals
  := (Dcuts_lim_cauchy_seq u Cu).
Definition Cauchy_seq_impl_ex_lim_seq (u : nat → NonnegativeReals) (Cu : Cauchy_seq u) : is_lim_seq u (Cauchy_lim_seq u Cu)
  := (Dcuts_Cauchy_seq_impl_ex_lim_seq u Cu).

(** Additionals theorems and definitions about limits *)

Lemma is_lim_seq_unique_aux (u : nat → NonnegativeReals) (l l' : NonnegativeReals) :
  is_lim_seq u l → is_lim_seq u l' → l < l' → empty.
Proof.
  intros u l l' Hl Hl' Hlt.
  assert (Hlt0 : 0 < l' - l).
  { now apply ispositive_minusNonnegativeReals. }
  assert (Hlt0' : 0 < (l' - l) / 2).
  { now apply ispositive_Dcuts_half. }
  generalize (Hl _ Hlt0') (Hl' _ Hlt0') ; clear Hl Hl'.
  apply (hinhuniv2 (P := hProppair _ isapropempty)).
  intros N M.
  generalize (pr2 N (max (pr1 N) (pr1 M)) (max_le_l _ _)) ; intros Hn.
  generalize (pr2 M (max (pr1 N) (pr1 M)) (max_le_r _ _)) ; intros Hm.
  apply (isirrefl_Dcuts_lt_rel ((l + l') / 2)).
  apply istrans_Dcuts_lt_rel with (u (max (pr1 N) (pr1 M))).
  - apply_pr2 (plusNonnegativeReals_ltcompat_l ((l' - l) / 2)).
    rewrite <- isdistr_Dcuts_half_plus.
    rewrite (iscomm_plusNonnegativeReals l), isassoc_plusNonnegativeReals, (iscomm_plusNonnegativeReals l).
    rewrite <- (minusNonnegativeReals_plus_r (l' - l) l' l), isdistr_Dcuts_half_plus, <- Dcuts_half_double.
    exact (pr2 Hm).
    now apply Dcuts_lt_le_rel.
    reflexivity.
  - pattern l' at 7 ;
    rewrite (minusNonnegativeReals_plus_r (l' - l) l' l), (iscomm_plusNonnegativeReals _ l), <- isassoc_plusNonnegativeReals, !isdistr_Dcuts_half_plus, <- Dcuts_half_double.
    exact (pr1 Hn).
    now apply Dcuts_lt_le_rel.
    reflexivity.
Qed.
Lemma is_lim_seq_unique (u : nat → NonnegativeReals) (l l' : NonnegativeReals) :
  is_lim_seq u l → is_lim_seq u l' → l = l'.
Proof.
  intros u l l' Hl Hl'.
  apply istight_apNonnegativeReals.
  unfold neg ;
  apply sumofmaps.
  - now apply (is_lim_seq_unique_aux u).
  - now apply (is_lim_seq_unique_aux u).
Qed.
Lemma isaprop_ex_lim_seq :
  Π u : nat -> NonnegativeReals, isaprop (Σ l : NonnegativeReals, is_lim_seq u l).
Proof.
  intros u l l'.
  apply (iscontrweqf (X := (pr1 l = pr1 l'))).
  now apply invweq, total2_paths_hProp_equiv.
  rewrite (is_lim_seq_unique _ _ _ (pr2 l) (pr2 l')).
  apply iscontrloopsifisaset.
  apply pr2.
Qed.
Definition ex_lim_seq  (u : nat → NonnegativeReals) : hProp
  := hProppair (Σ l : NonnegativeReals, is_lim_seq u l) (isaprop_ex_lim_seq u).
Definition Lim_seq (u : nat → NonnegativeReals) (Lu : ex_lim_seq u) : NonnegativeReals
  := pr1 Lu.

(** ** NonnegativeReals is a NonnegativeRig *)

Require Import UniMath.Topology.UniformSpace.
Require Import UniMath.Analysis.NormedSpace.
Require Import UniMath.Analysis.MetricSpace.

Definition NnR_NonnegativeReals : NonnegativeRig.
Proof.
  mkpair.
  apply (commrigtorig (pr1 NonnegativeReals)).
  mkpair.
  { exists minNonnegativeReals.
    exists maxNonnegativeReals.
    repeat split.
    - intros x y z ; apply isassoc_Dcuts_min.
    - intros x y ; apply iscomm_Dcuts_min.
    - intros x y z ; apply isassoc_Dcuts_max.
    - intros x y ; apply iscomm_Dcuts_max.
    - intros x y ; apply Dcuts_min_max.
    - intros x y ; apply Dcuts_max_min. }
  exists ltNonnegativeReals.
  repeat split ; simpl.
  - exists minusNonnegativeReals.
    intros x y.
    apply pathsinv0, maxNonnegativeReals_minus_plus.
  - intros H.
    apply Dcuts_min_carac_l, notlt_leNonnegativeReals, H.
  - intros <-.
    apply_pr2 notlt_leNonnegativeReals.
    apply Dcuts_min_le_r.
  - intros x y z.
    apply Dcuts_min_gt.
  - intros x y z.
    apply Dcuts_max_lt.
  - intros x y z.
    apply plusNonnegativeReals_ltcompat_r.
  - intros x y z.
    apply plusNonnegativeReals_ltcompat_l.
  - intros x y z.
    apply_pr2 plusNonnegativeReals_ltcompat_r.
  - intros x y z.
    apply_pr2 plusNonnegativeReals_ltcompat_l.
  - intros x y z t Hyx Htz.
    rewrite <- (maxNonnegativeReals_carac_r t z), iscomm_maxNonnegativeReals, maxNonnegativeReals_minus_plus.
    2: now apply lt_leNonnegativeReals.
    rewrite !isldistr_plus_multNonnegativeReals, iscomm_plusNonnegativeReals, !isassoc_plusNonnegativeReals.
    rewrite (iscomm_plusNonnegativeReals (x*t)).
    apply plusNonnegativeReals_ltcompat_l.
    apply multNonnegativeReals_ltcompat_l.
    apply ispositive_minusNonnegativeReals, Htz.
    exact Hyx.
  - intros x.
    apply Dcuts_min_carac_l, isnonnegative_NonnegativeReals.
  - exact ispositive_oneNonnegativeReals.
  - intros x.
    exists (halfNonnegativeReals x).
    split.
    rewrite <- double_halfNonnegativeReals.
    apply Dcuts_min_carac_l, isrefl_leNonnegativeReals.
    apply ispositive_halfNonnegativeReals.
Defined.

Definition NnM_NonnegativeReals : NonnegativeMonoid :=
  NonnegativeRig_to_NonnegativeAddMonoid NnR_NonnegativeReals.

Lemma NnMle_equiv :
  Π x y : NonnegativeReals, (x <= y)%NR <-> NnMle NnM_NonnegativeReals x y.
Proof.
  intros x y ; split.
  - apply Dcuts_min_carac_l.
  - intros <-.
    apply Dcuts_min_le_r.
Qed.

Definition MS_NonnegativeReals : MetricSet NnM_NonnegativeReals.
Proof.
  mkpair.
  exists NonnegativeReals.
  { exists apNonnegativeReals.
    repeat split.
    exact isirrefl_apNonnegativeReals.
    exact issymm_apNonnegativeReals.
    exact iscotrans_apNonnegativeReals.
    intros x y.
    apply (pr1 (istight_apNonnegativeReals _ _)). }
  exists (λ x y : NonnegativeReals, maxNonnegativeReals (x - y) (y - x)).
  repeat split.
  - intros x y.
    apply iscomm_maxNonnegativeReals.
  - intros [Hlt|Hlt].
    + eapply istrans_lt_le_ltNonnegativeReals, maxNonnegativeReals_le_r.
      apply ispositive_minusNonnegativeReals, Hlt.
    + eapply istrans_lt_le_ltNonnegativeReals, maxNonnegativeReals_le_l.
      apply ispositive_minusNonnegativeReals, Hlt.
  - apply hinhuniv.
    intros (r,(_)).
    apply hinhuniv.
    intros [Hr|Hr].
    + right.
      apply_pr2 ispositive_minusNonnegativeReals.
      now apply ispositive_apNonnegativeReals, Dcuts_notempty_notzero with r.
    + left.
      apply_pr2 ispositive_minusNonnegativeReals.
      now apply ispositive_apNonnegativeReals, Dcuts_notempty_notzero with r.
  - intros x y z.
    apply Dcuts_min_carac_l.
    rewrite isldistr_Dcuts_max_plus, !(iscomm_Dcuts_plus (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
    apply maxNonnegativeReals_le.
    + eapply istrans_leNonnegativeReals, Dcuts_max_le_l.
      eapply istrans_leNonnegativeReals, Dcuts_max_le_l.
      rewrite iscomm_Dcuts_plus.
      apply_pr2 (plusNonnegativeReals_lecompat_l z).
      rewrite isassoc_plusNonnegativeReals, <- !maxNonnegativeReals_minus_plus.
      rewrite isldistr_Dcuts_max_plus, <- maxNonnegativeReals_minus_plus.
      apply maxNonnegativeReals_le.
      * eapply istrans_leNonnegativeReals, Dcuts_max_le_l.
        apply Dcuts_max_le_l.
      * eapply istrans_leNonnegativeReals, Dcuts_max_le_r.
        apply Dcuts_plus_le_r.
    + eapply istrans_leNonnegativeReals, Dcuts_max_le_r.
      eapply istrans_leNonnegativeReals, Dcuts_max_le_r.
      apply_pr2 (plusNonnegativeReals_lecompat_l x).
      rewrite isassoc_plusNonnegativeReals, <- !maxNonnegativeReals_minus_plus.
      rewrite isldistr_Dcuts_max_plus, <- maxNonnegativeReals_minus_plus.
      apply maxNonnegativeReals_le.
      * eapply istrans_leNonnegativeReals, Dcuts_max_le_l.
        apply Dcuts_max_le_l.
      * eapply istrans_leNonnegativeReals, Dcuts_max_le_r.
        apply Dcuts_plus_le_r.
Defined.

Definition US_NonnegativeReals : UniformStructure NonnegativeReals :=
  metricUniformStructure (M := MS_NonnegativeReals).

Lemma CUS_NonnegativeReals :
  Π (F : Filter NonnegativeReals),
    isCauchy_filter US_NonnegativeReals F
    -> ex_filter_MSlim (M := MS_NonnegativeReals) F.
Proof.
  intros F Hf.

  assert (H : Π (e : NonnegativeReals) (He : (0 < e)%NR), US_NonnegativeReals (λ z : NonnegativeReals × NonnegativeReals, ball (M := MS_NonnegativeReals) (pr1 z) e (pr2 z))).
  { intros e He.
    apply hinhpr.
    now exists e. }
  generalize (λ (e : NonnegativeReals) (He : (0 < e)%NR), Hf _ (H e He)).
  unfold USsmall.
  clear Hf H ; intros Hf.
  simpl pr1 in Hf ; simpl pr2 in Hf.

  set (l := λ x : Dcuts, Π A, F A -> ∃ y : Dcuts, (x <= y)%Dcuts × A y).
  assert (Hl : Π x, isaprop (l x)).
  { intros x.
    apply impred_isaprop ; intros A.
    apply isapropimpl.
    apply propproperty. }

  apply hinhpr.
  mkpair.
  { apply (Dcuts_of_Dcuts (λ x, l x ,, Hl x)).
    - intros x Lx y Hy A Fa.
      generalize (Lx A Fa).
      apply hinhfun ; intros z.
      exists (pr1 z).
      split.
      apply istrans_leNonnegativeReals with x.
      exact Hy.
      apply (pr1 (pr2 z)).
      apply (pr2 (pr2 z)).
    - intros c Hc.
      generalize (Hf (c / 2) (pr1 (ispositive_halfNonnegativeReals _) Hc)).
      apply hinhuniv.
      intros A.
      generalize (NonnegativeReals_dense _ _ (pr1 (ispositive_halfNonnegativeReals _) Hc)).
      apply hinhuniv.
      intros r.
      generalize (filter_notempty _ _ (pr2 (pr2 A))).
      apply hinhuniv.
      intros a.
      generalize (is_Dcuts_error (pr1 a) _ (pr2 (NonnegativeRationals_to_NonnegativeReals_lt _ _) (pr1 (pr2 r)))).
      apply hinhfun.
      intros [Hc' | _].
      + left.
        intro Lc.
        generalize (Lc _ (pr2 (pr2 A))).
        apply hinhuniv'.
        apply isapropempty.
        intros y.
        generalize (pr1 (pr2 A) _ _ (pr2 a) (pr2 (pr2 y))).
        apply_pr2 notlt_leNonnegativeReals.
        eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
        apply_pr2 (plusNonnegativeReals_lecompat_l (pr1 a)).
        rewrite <- maxNonnegativeReals_minus_plus.
        eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
        eapply istrans_leNonnegativeReals, (pr1 (pr2 y)).
        pattern c at 3 ;
          rewrite (double_halfNonnegativeReals c).
        apply (pr1 (plusNonnegativeReals_lecompat_r _ _ _)).
        apply lt_leNonnegativeReals.
        eapply istrans_le_lt_ltNonnegativeReals, (pr2 (pr2 r)).
        Transparent Dcuts_le_rel.
        intros q Hq.
        simpl.
        apply notge_ltNonnegativeRationals.
        intros Hq'.
        apply Hc'.
        now apply is_Dcuts_bot with q.
      + right.
        apply hinhpr.
        exists (pr1 a - c / 2)%NR.
        split.
        * intros B Fb.
          generalize (filter_notempty _ _ (filter_and _ _ _ (pr2 (pr2 A)) Fb)).
          apply hinhfun.
          intros b.
          exists (pr1 b).
          split.
          apply_pr2 (plusNonnegativeReals_lecompat_l (c / 2)).
          rewrite <- maxNonnegativeReals_minus_plus.
          apply maxNonnegativeReals_le.
          eapply istrans_leNonnegativeReals.
          apply (maxNonnegativeReals_le_l _ (pr1 b)).
          rewrite maxNonnegativeReals_minus_plus, iscomm_plusNonnegativeReals.
          apply (pr1 (plusNonnegativeReals_lecompat_r _ _ _)).
          apply lt_leNonnegativeReals.
          eapply istrans_le_lt_ltNonnegativeReals, (pr1 (pr2 A) _ _ (pr2 a) (pr1 (pr2 b))).
          apply maxNonnegativeReals_le_l.
          apply plusNonnegativeReals_le_r.
          apply (pr2 (pr2 b)).
        * simpl.
          pattern c at 3 ;
            rewrite (double_halfNonnegativeReals c), <- isassoc_plusNonnegativeReals, <- maxNonnegativeReals_minus_plus, isrdistr_max_plusNonnegativeReals, <- double_halfNonnegativeReals.
          intros Ha.
          generalize (Ha _ (pr2 (pr2 A))) ; clear Ha.
          apply hinhuniv'.
          apply isapropempty.
          intros b.
          generalize (pr1 (pr2 A) _ _ (pr2 a) (pr2 (pr2 b))).
          apply_pr2 notlt_leNonnegativeReals.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          apply_pr2 (plusNonnegativeReals_lecompat_l (pr1 a)).
          rewrite <- maxNonnegativeReals_minus_plus, iscomm_plusNonnegativeReals.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, (pr1 (pr2 b)).
          apply maxNonnegativeReals_le_l. }

  set (x := Dcuts_of_Dcuts _ _ _).

  intros P.
  apply hinhuniv.
  intros e.
  eapply filter_imply.
  intros y.
  apply (pr2 (pr2 e)).
  generalize (pr1 e) (pr1 (pr2 e)) ; clear e ; intros e He.
  generalize (Hf _ (pr1 (ispositive_halfNonnegativeReals _) He)).
  apply hinhuniv.
  intros A.
  eapply filter_imply.
  intros y Hy.
  generalize (filter_notempty _ _ (pr2 (pr2 A))).
  apply hinhuniv.
  intros a.
  rewrite (double_halfNonnegativeReals e).
  eapply istrans_le_lt_ltNonnegativeReals, plusNonnegativeReals_le_ltcompat.
  apply_pr2 NnMle_equiv.
  apply (istriangle_dist (X := MS_NonnegativeReals) _ (pr1 a)).
  - apply maxNonnegativeReals_le.
    + apply_pr2 (plusNonnegativeReals_lecompat_l (pr1 a)).
      rewrite <- maxNonnegativeReals_minus_plus.
      apply maxNonnegativeReals_le.
      * intros r.
        apply hinhuniv.
        intros b.
        generalize (pr1 (pr2 b) _ (pr2 (pr2 A))).
        apply hinhuniv.
        intros c.
        generalize (pr2 (pr2 b)).
        apply istrans_leNonnegativeReals with (pr1 c).
        apply (pr1 (pr2 c)).
        eapply istrans_leNonnegativeReals.
        apply (maxNonnegativeReals_le_l _ (pr1 a)).
        rewrite maxNonnegativeReals_minus_plus.
        apply (pr1 (plusNonnegativeReals_lecompat_l _ _ _)).
        apply lt_leNonnegativeReals.
        eapply istrans_le_lt_ltNonnegativeReals, (pr1 (pr2 A)).
        apply maxNonnegativeReals_le_l.
        apply (pr2 (pr2 c)).
        apply (pr2 a).
      * apply plusNonnegativeReals_le_r.
    + apply_pr2 (plusNonnegativeReals_lecompat_l x).
      rewrite <- maxNonnegativeReals_minus_plus.
      apply maxNonnegativeReals_le.
      * eapply istrans_leNonnegativeReals.
        apply (maxNonnegativeReals_le_l _ (e / 2)).
        rewrite maxNonnegativeReals_minus_plus, iscomm_plusNonnegativeReals.
        apply (pr1 (plusNonnegativeReals_lecompat_r _ _ _)).
        intros r Hr.
        apply hinhpr.
        exists (pr1 a - e / 2)%NR.
        split.
        intros B Fb.
        generalize (filter_notempty _ _ (filter_and _ _ _ (pr2 (pr2 A)) Fb)).
        apply hinhfun.
        intros b.
        exists (pr1 b).
        split.
        apply_pr2 (plusNonnegativeReals_lecompat_l (e / 2)).
        rewrite <- maxNonnegativeReals_minus_plus.
        apply maxNonnegativeReals_le.
        eapply istrans_leNonnegativeReals.
        apply (maxNonnegativeReals_le_l _ (pr1 b)).
        rewrite maxNonnegativeReals_minus_plus, iscomm_plusNonnegativeReals.
        apply (pr1 (plusNonnegativeReals_lecompat_r _ _ _)).
        apply lt_leNonnegativeReals.
        eapply istrans_le_lt_ltNonnegativeReals, (pr1 (pr2 A) _ _ (pr2 a) (pr1 (pr2 b))).
        apply maxNonnegativeReals_le_l.
        apply plusNonnegativeReals_le_r.
        apply (pr2 (pr2 b)).
        exact Hr.
      * apply plusNonnegativeReals_le_r.
  - apply (pr1 (pr2 A)).
    apply (pr2 a).
    apply Hy.
  - apply (pr2 (pr2 A)).

Qed.


Lemma continuous_plusNonnegativeReals :
  MScontinuous2d (U := MS_NonnegativeReals) (V := MS_NonnegativeReals) (W := MS_NonnegativeReals) plusNonnegativeReals.
Proof.
  intros x y.
  refine (pr2 (is_MSlim_aux _ _ _) _).
  intros e He.
  simple refine (filter_imply (FilterDirprod _ _) _ _ _ _).
  { intros (x',y').
    apply hconj.
    apply (ball x (e / 2) x').
    apply (ball y (e / 2) y'). }
  { intros (x',y') (Hx,Hy).
    unfold ball ; simpl.
    rewrite (double_halfNonnegativeReals e).
    apply istrans_le_lt_ltNonnegativeReals with (dist x x' + dist y y')%NR.
    - unfold dist ; simpl.
      rewrite isldistr_Dcuts_max_plus.
      rewrite !(iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
      apply Dcuts_max_le.
      + eapply istrans_leNonnegativeReals, Dcuts_max_le_l.
        eapply istrans_leNonnegativeReals, Dcuts_max_le_l.
        apply_pr2 (plusNonnegativeReals_lecompat_l (x' + y')%NR).
        rewrite <- maxNonnegativeReals_minus_plus.
        rewrite !isassoc_plusNonnegativeReals, <- (isassoc_plusNonnegativeReals (x - x')%NR).
        rewrite <- maxNonnegativeReals_minus_plus.
        rewrite (iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), <- isassoc_plusNonnegativeReals.
        rewrite <- maxNonnegativeReals_minus_plus.
        rewrite isldistr_Dcuts_max_plus.
        rewrite !(iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
        apply Dcuts_max_le.
        * eapply istrans_leNonnegativeReals, Dcuts_max_le_l.
          apply Dcuts_max_le_l.
        * eapply istrans_leNonnegativeReals, Dcuts_max_le_r.
          apply Dcuts_max_le_r.
      + eapply istrans_leNonnegativeReals, Dcuts_max_le_r.
        eapply istrans_leNonnegativeReals, Dcuts_max_le_r.
        apply_pr2 (plusNonnegativeReals_lecompat_l (x + y)%NR).
        rewrite <- maxNonnegativeReals_minus_plus.
        rewrite !isassoc_plusNonnegativeReals, <- (isassoc_plusNonnegativeReals (x' - x)%NR).
        rewrite <- maxNonnegativeReals_minus_plus.
        rewrite (iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), <- isassoc_plusNonnegativeReals.
        rewrite <- maxNonnegativeReals_minus_plus.
        rewrite isldistr_Dcuts_max_plus.
        rewrite !(iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
        apply Dcuts_max_le.
        * eapply istrans_leNonnegativeReals, Dcuts_max_le_l.
          apply Dcuts_max_le_l.
        * eapply istrans_leNonnegativeReals, Dcuts_max_le_r.
          apply Dcuts_max_le_r.
    - apply plusNonnegativeReals_ltcompat.
      exact Hx.
      exact Hy. }
  apply hinhpr.
  exists (ball x (e / 2)), (ball y (e / 2)).
  repeat split.
  - apply MSlocally_ball.
    now apply ispositive_halfNonnegativeReals, He.
  - apply MSlocally_ball.
    now apply ispositive_halfNonnegativeReals, He.
  - exact X.
  - exact X0.
Qed.

Lemma continuous_minusNonnegativeReals :
  MScontinuous2d (U := MS_NonnegativeReals) (V := MS_NonnegativeReals) (W := MS_NonnegativeReals) minusNonnegativeReals.
Proof.
  intros x y.
  refine (pr2 (is_MSlim_aux _ _ _) _).
  intros e He.
  simple refine (filter_imply (FilterDirprod _ _) _ _ _ _).
  { intros (x',y').
    apply hconj.
    apply (ball x (e / 2) x').
    apply (ball y (e / 2) y'). }
  { intros (x',y') (Hx,Hy).
    unfold ball ; simpl.
    rewrite (double_halfNonnegativeReals e).
    apply istrans_le_lt_ltNonnegativeReals with (dist x x' + dist y y')%NR.
    - unfold dist ; simpl.
      rewrite isldistr_Dcuts_max_plus.
      rewrite !(iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
      apply Dcuts_max_le.
      + apply_pr2 (plusNonnegativeReals_lecompat_r (x' - y')%NR).
        rewrite !isldistr_Dcuts_max_plus, !(iscomm_plusNonnegativeReals (x' - y')), <- maxNonnegativeReals_minus_plus.
        apply Dcuts_max_le.
        * apply_pr2 (plusNonnegativeReals_lecompat_r y).
          rewrite !isldistr_Dcuts_max_plus, <- !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals y).
          rewrite <- !maxNonnegativeReals_minus_plus.
          rewrite !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
          rewrite !isassoc_plusNonnegativeReals, <- !maxNonnegativeReals_minus_plus.
          rewrite !isldistr_Dcuts_max_plus, <- !maxNonnegativeReals_minus_plus.
          apply Dcuts_max_le.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          apply maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, plusNonnegativeReals_le_r.
          apply plusNonnegativeReals_le_l.
        * apply_pr2 (plusNonnegativeReals_lecompat_r y').
          rewrite !isldistr_Dcuts_max_plus, <- !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals y').
          rewrite <- !maxNonnegativeReals_minus_plus.
          rewrite !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
          rewrite !isassoc_plusNonnegativeReals, <- !maxNonnegativeReals_minus_plus.
          rewrite !isldistr_Dcuts_max_plus, <- !maxNonnegativeReals_minus_plus.
          apply Dcuts_max_le.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          apply maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          apply plusNonnegativeReals_le_r.
      + apply_pr2 (plusNonnegativeReals_lecompat_r (x - y)%NR).
        rewrite !isldistr_Dcuts_max_plus, !(iscomm_plusNonnegativeReals (x - y)), <- maxNonnegativeReals_minus_plus.
        apply Dcuts_max_le.
        * apply_pr2 (plusNonnegativeReals_lecompat_r y').
          rewrite !isldistr_Dcuts_max_plus, <- !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals y').
          rewrite <- !maxNonnegativeReals_minus_plus.
          rewrite !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
          rewrite !isassoc_plusNonnegativeReals, <- !maxNonnegativeReals_minus_plus.
          rewrite !isldistr_Dcuts_max_plus, <- !maxNonnegativeReals_minus_plus.
          apply Dcuts_max_le.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          apply maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, plusNonnegativeReals_le_r.
          apply plusNonnegativeReals_le_r.
        * apply_pr2 (plusNonnegativeReals_lecompat_r y).
          rewrite !isldistr_Dcuts_max_plus, <- !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals y).
          rewrite <- !maxNonnegativeReals_minus_plus.
          rewrite !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals (maxNonnegativeReals _ _)), !isldistr_Dcuts_max_plus.
          rewrite !isassoc_plusNonnegativeReals, <- !maxNonnegativeReals_minus_plus.
          rewrite !isldistr_Dcuts_max_plus, <- !maxNonnegativeReals_minus_plus.
          apply Dcuts_max_le.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          apply maxNonnegativeReals_le_r.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
          eapply istrans_leNonnegativeReals, plusNonnegativeReals_le_r.
          apply plusNonnegativeReals_le_l.
    - apply plusNonnegativeReals_ltcompat.
      exact Hx.
      exact Hy. }
  apply hinhpr.
  exists (ball x (e / 2)), (ball y (e / 2)).
  repeat split.
  - apply MSlocally_ball.
    now apply ispositive_halfNonnegativeReals, He.
  - apply MSlocally_ball.
    now apply ispositive_halfNonnegativeReals, He.
  - exact X.
  - exact X0.
Qed.

Lemma continuous_multNonnegativeReals :
  MScontinuous2d (U := MS_NonnegativeReals) (V := MS_NonnegativeReals) (W := MS_NonnegativeReals) multNonnegativeReals.
Proof.
  assert (H : Π x, (x + 1 ≠ 0)%NR).
    { clear ; intros x.
      apply_pr2 ispositive_apNonnegativeReals.
      eapply istrans_le_lt_ltNonnegativeReals, plusNonnegativeReals_lt_r.
      apply isnonnegative_NonnegativeReals.
      apply ispositive_oneNonnegativeReals. }
  intros x y.
  refine (pr2 (is_MSlim_aux _ _ _) _).
  intros e He.

  simple refine (filter_imply (FilterDirprod _ _) _ _ _ _).
  { intros (x',y').
    apply hconj.
    apply (ball x (divNonnegativeReals (e / 2) _ (H y)) x').
    apply (ball y (minNonnegativeReals (divNonnegativeReals (e / 2) _ (H x)) 1) y'). }
  { intros (x',y') (Hx,Hy).
    unfold ball ; simpl.
    rewrite (double_halfNonnegativeReals e).
    apply istrans_le_lt_ltNonnegativeReals with (x * dist y y' + (dist x x') * y')%NR.
    unfold dist ; simpl.
    rewrite isldistr_max_multNonnegativeReals, isrdistr_max_multNonnegativeReals.
    rewrite isldistr_max_plusNonnegativeReals, !isrdistr_max_plusNonnegativeReals.
    apply maxNonnegativeReals_le.
    - apply_pr2 (plusNonnegativeReals_lecompat_l (x' * y')).
      rewrite !isrdistr_max_plusNonnegativeReals, !isassoc_plusNonnegativeReals, <- !isrdistr_plus_multNonnegativeReals.
      rewrite <- !maxNonnegativeReals_minus_plus.
      rewrite isrdistr_max_multNonnegativeReals, !isldistr_max_plusNonnegativeReals.
      rewrite <- !isldistr_plus_multNonnegativeReals.
      rewrite <- !maxNonnegativeReals_minus_plus.
      rewrite !isldistr_max_multNonnegativeReals.
      apply maxNonnegativeReals_le.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
      apply maxNonnegativeReals_le_l.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
      apply plusNonnegativeReals_le_r.
    - apply_pr2 (plusNonnegativeReals_lecompat_r (x * y)).
      rewrite !isldistr_max_plusNonnegativeReals, <- !isassoc_plusNonnegativeReals, !(iscomm_plusNonnegativeReals (x * y)), <- !isldistr_plus_multNonnegativeReals.
      rewrite <- !maxNonnegativeReals_minus_plus.
      rewrite isldistr_max_multNonnegativeReals, !isrdistr_max_plusNonnegativeReals.
      rewrite <- !isrdistr_plus_multNonnegativeReals, !(iscomm_plusNonnegativeReals x).
      rewrite <- !maxNonnegativeReals_minus_plus.
      rewrite !isrdistr_max_multNonnegativeReals.
      apply maxNonnegativeReals_le.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_l.
      apply maxNonnegativeReals_le_l.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
      eapply istrans_leNonnegativeReals, maxNonnegativeReals_le_r.
      apply plusNonnegativeReals_le_l.
    - apply plusNonnegativeReals_ltcompat.
      + eapply istrans_le_lt_ltNonnegativeReals.
        apply multNonnegativeReals_lecompat_l'.
        apply (plusNonnegativeReals_le_l _ 1).
        eapply istrans_lt_le_ltNonnegativeReals.
        eapply multNonnegativeReals_ltcompat_r.
        apply ispositive_apNonnegativeReals, H.
        eapply istrans_lt_le_ltNonnegativeReals, Dcuts_min_le_l.
        apply Hy.
        unfold divNonnegativeReals.
        rewrite iscomm_multNonnegativeReals, isassoc_multNonnegativeReals, islinv_invNonnegativeReals, isrunit_one_multNonnegativeReals.
        apply isrefl_leNonnegativeReals.
      + eapply istrans_le_lt_ltNonnegativeReals.
        apply multNonnegativeReals_lecompat_r'.
        instantiate (1 := (y + 1)%NR).
        eapply istrans_leNonnegativeReals.
        apply maxNonnegativeReals_le_l.
        rewrite maxNonnegativeReals_minus_plus, iscomm_plusNonnegativeReals.
        apply plusNonnegativeReals_lecompat_r.
        eapply istrans_leNonnegativeReals, Dcuts_min_le_r.
        eapply istrans_leNonnegativeReals, lt_leNonnegativeReals, Hy.
        apply maxNonnegativeReals_le_r.
        eapply istrans_lt_le_ltNonnegativeReals.
        eapply multNonnegativeReals_ltcompat_l.
        apply ispositive_apNonnegativeReals, H.
        apply Hx.
        unfold divNonnegativeReals.
        rewrite isassoc_multNonnegativeReals, islinv_invNonnegativeReals, isrunit_one_multNonnegativeReals.
        apply isrefl_leNonnegativeReals. }
  apply hinhpr.
  exists (ball x (divNonnegativeReals (e / 2) (y + 1)%NR (H y))), (ball y
              (minNonnegativeReals
                 (divNonnegativeReals (e / 2) (x + 1)%NR (H x)) 1)).
  repeat split.
  - apply MSlocally_ball.
    eapply istrans_le_lt_ltNonnegativeReals, multNonnegativeReals_ltcompat_r.
    apply isnonnegative_NonnegativeReals.
    apply ispositive_halfNonnegativeReals, He.
    apply (multNonnegativeReals_ltcompat_r' (y + 1)%NR).
    rewrite israbsorb_zero_multNonnegativeReals, isrinv_invNonnegativeReals.
    apply ispositive_oneNonnegativeReals.
  - apply MSlocally_ball.
    apply Dcuts_min_gt.
    eapply istrans_le_lt_ltNonnegativeReals, multNonnegativeReals_ltcompat_r.
    apply isnonnegative_NonnegativeReals.
    apply ispositive_halfNonnegativeReals, He.
    apply (multNonnegativeReals_ltcompat_r' (x + 1)%NR).
    rewrite israbsorb_zero_multNonnegativeReals, isrinv_invNonnegativeReals.
    apply ispositive_oneNonnegativeReals.
    apply ispositive_oneNonnegativeReals.
  - exact X.
  - exact X0.
Qed.

Lemma continuous_invNonnegativeReals :
  MScontinuous_on (U := MS_NonnegativeReals) (V := MS_NonnegativeReals) (λ x, (x ≠ 0)%NR) invNonnegativeReals.
Proof.
  intros x Hx.
  apply hinhpr.
  mkpair.
  { intros P.
    apply hinhfun.
    intros e.
    exists (x + (pr1 e) / 2)%NR.
    split.
    apply_pr2 ispositive_apNonnegativeReals.
    eapply istrans_le_lt_ltNonnegativeReals, (pr1 (plusNonnegativeReals_lt_r _ _)).
    apply isnonnegative_NonnegativeReals.
    apply (pr1 (ispositive_halfNonnegativeReals _)), (pr1 (pr2 e)).
    apply (pr2 (pr2 e)).
    generalize (pr1 e) (pr1 (pr2 e)) ; clear e ; intros e He.
    unfold ball ; simpl.
    unfold dist ; simpl.
    rewrite minusNonnegativeReals_eq_zero, maxNonnegativeReals_carac_r.
    rewrite <- (minusNonnegativeReals_correct_l _ _ _ (idpath _)).
    pattern e at 2 ;
      rewrite (double_halfNonnegativeReals e).
    apply (pr1 (plusNonnegativeReals_lt_r _ _)), (pr1 (ispositive_halfNonnegativeReals _)), He.
    apply isnonnegative_NonnegativeReals.
    apply plusNonnegativeReals_le_l. }

  refine (pr2 (is_MSlim_aux _ _ _) _).
  intros e He.
  apply hinhpr.
  exists (minNonnegativeReals (e * x * (x / 2))%NR (x / 2)).
  split.
  - apply Dcuts_min_gt.
    change (0 < e * x * (x / 2)%NR)%NR.
    rewrite <- (islabsorb_zero_multNonnegativeReals (x / 2)%NR).
    apply multNonnegativeReals_ltcompat_l.
    apply ispositive_halfNonnegativeReals, ispositive_apNonnegativeReals, Hx.
    rewrite <- (islabsorb_zero_multNonnegativeReals x).
    apply multNonnegativeReals_ltcompat_l.
    apply ispositive_apNonnegativeReals, Hx.
    apply He.
    apply ispositive_halfNonnegativeReals, ispositive_apNonnegativeReals, Hx.
  - intros y Hy Hy0.
    apply multNonnegativeReals_ltcompat_l' with (x * y)%NR.
    unfold dist ; simpl.
    rewrite isrdistr_max_multNonnegativeReals, !isrdistr_minus_multNonnegativeReals.
    rewrite <- isassoc_multNonnegativeReals, islinv_invNonnegativeReals, islunit_one_multNonnegativeReals.
    rewrite iscomm_multNonnegativeReals, isassoc_multNonnegativeReals, isrinv_invNonnegativeReals, isrunit_one_multNonnegativeReals.
    rewrite iscomm_maxNonnegativeReals.
    eapply istrans_lt_le_ltNonnegativeReals.
    apply Hy.
    eapply istrans_leNonnegativeReals.
    apply Dcuts_min_le_l.
    rewrite <- isassoc_multNonnegativeReals.
    apply multNonnegativeReals_lecompat_r'.
    apply_pr2 (plusNonnegativeReals_lecompat_r (x / 2)).
    rewrite <- double_halfNonnegativeReals.
    eapply istrans_leNonnegativeReals.
    apply maxNonnegativeReals_le_l.
    rewrite maxNonnegativeReals_minus_plus.
    apply plusNonnegativeReals_lecompat_l.
    eapply istrans_leNonnegativeReals, lt_leNonnegativeReals.
    apply maxNonnegativeReals_le_l.
    eapply istrans_lt_le_ltNonnegativeReals, Dcuts_min_le_r.
    apply Hy.
Qed.

(* End of the file NonnegativeReals.v *)
