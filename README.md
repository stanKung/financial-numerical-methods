# 財務數值方法學習成果 (MATLAB)

以 MATLAB 實作固定收益與衍生性商品定價，涵蓋數值求根、Monte Carlo、控制變量、隨機波動模型、最小平方蒙地卡羅及障礙選擇權二項樹。

[瀏覽全部八張圖表](GALLERY.md)

## 成果簡介

### 亞式選擇權：模擬估價與不確定性

比較普通 Monte Carlo 與 randomized Sobol + control variate，以不同路徑數觀察估價及區間寬度。算術與幾何平均均包含初始價格及其後60個觀察點；幾何平均控制變量使用相同離散觀察時間的解析期望。

![Asian option convergence](figures/hw10_asian_convergence.png)

圖中路徑數是估價使用的總路徑數；Sobol每個樣本數分成10組獨立scramble，另使用4096條獨立pilot路徑估計控制變量係數。QMC區間由各組均值計算近似t區間，並非確定性誤差界；此圖不代表相同執行時間的效率比較。

### Heston 與美式賣權：模擬、回歸與履約

模擬相關的價格及變異數過程，以三次多項式回歸估計繼續持有價值，再與立即履約價值比較。圖中歐式價格取自相同Heston路徑，呈現美式與僅到期履約之間的估價差異。

![Heston American put](figures/hw11_american_put.png)

變異數採反射Euler離散，外國利率設定為0。回歸與估價使用同批路徑，仍有樣本內估計與時間離散誤差；圖中的價格差為有限樣本估計。不同初始價格使用相同亂數設定，便於比較；不是互相獨立的實驗。

### 障礙選擇權：商品結構與定價關係

以50步CRR二項樹計算下方障礙買權，改變障礙水準，比較knock-in、knock-out及普通買權價格，並驗證In-Out Parity。

![Barrier option values](figures/hw13_barrier_options.png)

障礙只在樹的時間節點監測，觸及障礙即生效／失效，無回饋金。敏感度曲線的階梯形狀來自固定二項樹的離散節點，不是繪圖錯誤；結果不等同連續監測價格。

## 更多視覺化

| 圖表 | 觀察重點 | 結果資料 |
|---|---|---|
| [債券與存續期間](figures/hw07_bond_duration.png) | 價格—殖利率關係與一階近似的誤差 | [CSV](results/hw07_bond_duration.csv) |
| [隱含波動率](figures/hw08_implied_volatility.png) | 合成報價的波動率反解及二分法停止條件 | [CSV](results/hw08_iv_recovery.csv) |
| [歐式選擇權Monte Carlo](figures/hw09_monte_carlo.png) | 估價區間、Black–Scholes基準與平價誤差 | [CSV](results/hw09_monte_carlo.csv) |
| [Heston模擬路徑](figures/hw11_heston_paths.png) | 價格與隨機波動度的共同演化 | [CSV](results/hw11_sample_paths.csv) |
| [彩虹選擇權](figures/hw12_rainbow_option.png) | 相關資產預測路徑與折現payoff分布 | [CSV](results/hw12_rainbow_summary.csv) |

隱含波動率展示使用模型產生的合成報價，並非市場波動率微笑。MC收斂圖為固定種子下的單次實驗，誤差不必隨樣本數單調下降。彩虹選擇權以課程資料估計波動度及相關性，採無股息GBM、252日年化，平均只包含13個預測交易日。


## 課程內容索引

| 作業 | 主題 | 入口 |
|---|---|---|
| HW1 | 浮點數與數值誤差 | [PDF](coursework/HW1_112705018/HW1_112705018.pdf) |
| HW2–HW3 | 資料讀寫、描述統計、利率計算、最小平方法 | `coursework/HW2_112705018/`、`HW3_112705018/` |
| HW4 | 多元迴歸、殘差及條件篩選 | `coursework/HW4_112705018/` |
| HW5 | 字元處理與資料篩選 | `coursework/HW5_112705018/` |
| HW6 | 商業本票、Black–Scholes、Merton模型 | `Price_cal`、`BS_put_parity`、`Merton` |
| HW7 | 存續期間與殖利率求根 | `MacaulayDuration`、`Yield` |
| HW8 | 隱含波動率 | `implied_vol` |
| HW9 | 歐式選擇權Monte Carlo與Put–Call Parity | `HW9_112705018.m` |
| HW10 | 算術平均亞式賣權、Sobol與控制變量 | `HW10_112705018.m` |
| HW11 | Heston及Least Squares Monte Carlo | `Heston_Leastsquare` |
| HW12 | 三資產彩虹選擇權 | `HW12_112705018.m` |
| HW13 | 下方障礙選擇權及In-Out Parity | `CRR_Barrier_Price` |
