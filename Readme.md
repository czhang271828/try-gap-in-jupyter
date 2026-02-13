# 使用 GAP 绘制有限维代数的 AR Quiver

## 启动容器

在 [Binder](https://mybinder.org/) 中打开 GitHub 仓库. 依次完成以下两个步骤即可, 请勿进行多余动作.

1. 确认 `GitHub repository name or URL` 一栏显示 `GitHub`. 在右侧粘贴 `https://github.com/czhang271828/GAP_Online`.
2. 直接点击 `Launch` 按钮.
3. 等待环境启动完成. 随后 Binder 会自动跳转至 Jupyter Notebook 页面.

若浏览器未能成功跳转页面, 则请点击 `view raw`, 并在新标签页中打开链接. `Jupyter Notebook` 的链接通常出现在 `server running at ...` 处.

- 此处的复制键可能是 `Ctrl + Insert` 而非 `Ctrl + C`.

## 进入 Jupyter Notebook

进入 Jupyter Notebook 后, 浏览器上的地址形如 `https://hub.gesis.mybinder.org/user/czhang271828-gap_online-xxxx/tree`. 此时 root 目录下出现以下三项

- `Dockerfile`: 这是搭建环境的说明文件, 供开发者使用. 用户无需关注.
- `Readme.md`: 这是说明文档.
- `ARquiver`: 这是绘制 ARquiver 的文件夹.

### Step1.txt

路代数信息存放于 `Step1.txt` 文件中. 文件格式如

```
vertices: 4

edges: 
    1 2 alpha
    2 3 beta
    3 1 gamma
    4 1 delta

rel: 
    alpha beta
    delta alpha
    beta gamma alpha
    

style:
    1-2-
    -3-4
    
depth: 20

file: example

guess: F
```

以上文本中,

- `vertices:` 后接顶点数. 默认顶点为 $1,2,\dots, n$.
- `edges:` 后接边. 例如, 若图中存在一条边 $\alpha : 1 \to 2$, 则在 `edges` 一栏中添加 `1 2 alpha`. 请在录入新边前使用换行与 `tab` 缩进.
- `rel:` 后接关系. 例如, 若图中存在关系 $\beta \circ \alpha = 0$, 则请输入 `alpha*beta`. 一个空格 ` ` 将严格转义为 `*`. 请勿在表述中增加多余的空格. 请在录入新关系前使用换行与 `tab` 缩进.
`style:` 后接维数向量的排列方式. `-` 表示占位符. 示例代码将维数向量的排列方式设定为 $\left[\begin{smallmatrix}v_1 & & v_2 & \\ & v_3 & & v_4\end{smallmatrix}\right]$.
- `depth` 表示 AR quiver 计算深度. 建议先使用 `depth: 4` 进行测试. 若后续计算速度较快, 则可以加大深度.
  - 部分代数可能不是有限表示的, 则以上计算结果为其预投射分支的局部.
- `file:` 后接文件名称. 后续将输出 `quiver_name.txt` 与 `diagram_name.html` 两个文件.
- `guess:` 后接 `T` 或 `F`. 若使用 `T`, 则会通过某种成功率较高的算法猜测不可约态射, 速度相对快一些.

### Step2.ipynb

**`Step1.txt` 中描述的的路代数是 $\mathbb Q$ 上的, 且支持重边, 自环与定向圈.**

保存 `Step1.txt` 后, 进入 `Step2.ipynb` 文件. 请点击 `Cell > Run All` 以运行所有单元格. 运行完成后, 会将在当前目录下生成 `quiver_name.txt`, 其中包括了绘图所需的所有信息.

注意: 较新版本的 `GAP` 无法在 Jupyter 环境中运行, 因此 Binder 中的 `GAP` 是较旧版本. 这可能会导致部分代码 (例如 `IrreducibleMorphismsStartingIn(M)`) 不存在.

### Step3.ipynb

请先确保 `quiver_name.txt` 已经生成. 随后进入 `Step3.ipynb` 文件. 请点击 `Cell > Run All` 以运行所有单元格. 运行完成后, 会在当前目录下生成 `diagram_name.html`, 其中包含了 AR quiver 的可视化图像.

注意: 在线环境使用 `Python3.6` (2016 年发行, 2021 年停止支持). 这可能会导致部分代码 (例如 `f-string`) 无法使用. 请谨慎修改相关代码.

### Diagram.html

打开 `diagram_name.html` 文件, 即可查看 AR quiver 的可视化图像. 先介绍几个核心功能:

- `Irr`: 不可约态射.
- `tau`: AR 平移. 长按橙色箭头可以校准后续.
- `Ctrl + Z` : 撤销上一步操作. 例如, 若误删了某条边, 则可以使用 `Ctrl + Z` 恢复.
- 选中某(几)条边后, 可使用键盘左右键调整边的弧度.

可以使用如下步骤, 快速绘制较美观且个性化的 AR quiver:

- 找到所有蓝/紫色节点, 并在一块较干净的区域排列. 最终使投射对象间的箭头朝着左下或右下.
  - 蓝色/红色/紫色节点表示投射对象/内射对象/投射-内射对象.
- 找到 $\tau^{-1}P_i$, 也就是让指向投射模的橙色箭头保持水平.
- 取消对所有点/边的选择, 长按已水平化的橙色箭头, 以校准后续的 $\tau$ 平移. 如果长按无效, 那多半是因为 $\tau$ 平移箭头的底下藏着不可约态射. 可以调整弧度, 将被遮挡的 `Irr` 箭头分离.
- 绘图完成后, 请取消对 `tau` 的选择, 检查有无被遮盖的 `Irr` 箭头.

之后是一些附加功能:

- `Label` 小窗口显示节点标号, 方便在 `Step2.txt` 中顶点信息.
- `PDID` 显示投射/内射维数. $-1$ 表示无穷.
- `Quiver` 这一小窗口显示了路代数的底图. 顶点排列与维数向量一致.
- `Tilting` 小窗口的无向图中, 一个顶点是一个 Tilting 模. 两个 Tilting 模相邻, 当且仅当他们相邻一个不可分解对象. 在选择一个 Tilting 模后,
  - 灰色节点表示 Tilting 模的直和项,
  - 橙色节点表示 Torsion 类,
  - 绿色节点表示 Torsionfree 类.
- 其他功能请自行探索. 有时读表比看图更方便.
