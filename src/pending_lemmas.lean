/-
  The lemmas in this file will soon be in mathlib
-/

import data.list.basic

open list nat

variables {α : Type*} {β : Type*}

theorem nth_map (f : α → β) : ∀ l n, nth (map f l) n = (nth l n).map f
| []       n     := rfl
| (a :: l) 0     := rfl
| (a :: l) (n+1) := nth_map l n

theorem nth_le_map (f : α → β) {l n} (H1 H2) : nth_le (map f l) n H1 = f (nth_le l n H2) :=
option.some.inj $ by rw [← nth_le_nth, nth_map, nth_le_nth]; refl

theorem map_add_range' (a) : ∀ s n : ℕ, map ((+) a) (range' s n) = range' (a + s) n
| s 0     := rfl
| s (n+1) := congr_arg (cons _) (map_add_range' (s+1) n)

theorem range_succ_eq_map (n : ℕ) : range (n + 1) = 0 :: map succ (range n) :=
by rw [range_eq_range', range_eq_range', range',
       add_comm, ← map_add_range'];
   congr; exact funext one_add

theorem reverse_range' : ∀ s n : ℕ,
  reverse (range' s n) = map (λ i, s + n - 1 - i) (range n)
| s 0     := rfl
| s (n+1) := by rw [range'_concat, reverse_append, range_succ_eq_map];
  simpa [show s + (n + 1) - 1 = s + n, from rfl, (∘),
    λ a i, show a - 1 - i = a - succ i,
    by rw [nat.sub_sub, add_comm]; refl]
  using reverse_range' s n

theorem range'_eq_map_range (s n : ℕ) : range' s n = map ((+) s) (range n) :=
by rw [range_eq_range', map_add_range']; refl

lemma reverse_range'_map_range' (a b : ℕ) : reverse (range' a (b+1-a)) = map (λ i, a+b-i) (range' a (b+1-a)) :=
begin
  rw [reverse_range', range'_eq_map_range, map_map],
  apply map_congr, intros i H,
  simp at *,
  rw [nat.add_sub_add_left, nat.add_sub_cancel'], {refl},
  apply le_of_not_le (λ h, _),
  rw sub_eq_zero_of_le h at H,
  exact not_lt_zero _ H
end


lemma filter_congr {α : Type*} {p q : α → Prop} [decidable_pred p] [decidable_pred q]
  : ∀ {l : list α}, (∀ x ∈ l, p x ↔ q x) → filter p l = filter q l
| [] _     := rfl
| (a::l) h := by simp at h; by_cases pa : p a;
  [simp [pa, h.1.1 pa, filter_congr h.2],
   simp [pa, mt h.1.2 pa, filter_congr h.2]]

lemma filter_ext {α : Type*} {r: list α} (P P') [decidable_pred P] [decidable_pred P'] 
  (HP : ∀ i ∈ r, P i = P' i) : filter P r = filter P' r :=
begin
  induction r with h t IH,
  { simp },
  { have HPh : P h = P' h := HP h (by simp),
    have : ∀ (i : α), i ∈ t → P i = P' i,
    { intros i i_t,
      exact (HP i $ by simp [i_t]) },
    by_cases H : P h, 
    { have H' : P' h := HPh ▸ H,
      simp [H, H', IH this] },
    { have H' : ¬ P' h := HPh ▸ H, 
      simp [H, H', IH this] } }
end

lemma foldr_ext {α : Type*} {β : Type*} {l : list α} (f f' : α → β → β) (s : β)
  (H : ∀ a ∈ l, ∀ b : β, f a b = f' a b) : foldr f s l = foldr f' s l :=
by induction l; simp * {contextual := tt}

lemma range'_add_map (a b k : ℕ) : range' (a+k) b = map (λ x, x + k) (range' a b) :=
begin
  revert a,
  induction b with b IH; intro a,
  { refl },
  { simpa using (IH $ a + 1) }
end

lemma range'_sub_map (a b k : ℕ) : range' a b = map (λ x, x - k) (range' (a+k) b) :=
begin
  suffices : (λ (x : ℕ), x - k) ∘ (λ (x : ℕ), x + k) = id,
  { rw [range'_add_map, map_map, this, map_id] },
  { funext, simp [nat.add_sub_cancel_left] }
end


lemma filter_map_comm {I : Type*} {J : Type*} (f : I → J) (P : J → Prop) (r: list I) [decidable_pred P] :
  filter P (map f r) = map f (filter (P ∘ f) r) :=
begin
  induction r with h _ IH,
  { simp },
  { by_cases H : P (f h) ; simp [filter_cons_of_pos, filter_cons_of_neg, H, IH] }
end

