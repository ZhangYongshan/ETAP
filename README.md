# Efficient Tensorized Multi-View Anchor Graph Clustering with Affinity Propagation for Remote Sensing Data
+ Code for the paper: "Yongshan Zhang, Kangyue Zheng, Shuaikang Yan, Xinxin Wang2*, Zhihua Cai.Efficient Tensorized Multi-View Anchor Graph Clustering with Affinity Propagation for Remote Sensing Data",AAAI，2026.

# Method
## Overall Structure
Overall framework of ETAP. Based on superpixel denoising and anchor initialization, ETAP is formulated as a unified framework that simultaneously performs anchor graph learning and compressed anchor graph learning for each view, with tensor Schatten $p$-norm regularization and a connectivity constraint applied to the compressed anchor graphs. After optimization, a weighted affinity propagation strategy is employed to achieve pixel partitioning based on the compressed anchor graphs with optimal clustering structures.

![](https://cdn.nlark.com/yuque/0/2025/jpeg/51372487/1763368290542-69f9278f-bba7-4cb2-9b6a-9d694871e7b1.jpeg)

## Affinity propagation
![](./readme_image/CMAFB.jpg#pic_center)Finally, the clustering labels of pixels can be revealed through affinity propagation based on the structured anchors in ![image](https://cdn.nlark.com/yuque/__latex/dbd74fcf1e5de0b2c29a4fdf6435decd.svg) and the weighted anchor graph ![image](https://cdn.nlark.com/yuque/__latex/ce727ce2aa1caa1872f00eec5bf618e0.svg).Specifically, a multi-view pixel is assigned the same label as the anchor that exhibits the maximum affinity with the pixel in ![image](https://cdn.nlark.com/yuque/__latex/1d06f8e675646c1e1564fed2133dafde.svg). Thus, the clustering structures of pixels are efficiently obtained. The figure illustrates the affinity propagation strategy used for pixel label inference.

![](https://cdn.nlark.com/yuque/0/2025/jpeg/51372487/1763368355609-68629e54-f15c-4a14-8ca5-b09c022283b8.jpeg)

# Experimental Results
+ Quantitative evalutaion results on Berlin, MUUFL and MDAS.

![](./readme_image/table_compare.png#pic_center)![](https://cdn.nlark.com/yuque/0/2025/png/51372487/1763369248768-46fbb3c6-cfbb-48ac-88dc-26d6e5916240.png)

+ Qualitative evalutaion results on the MUUFL dataset.

![](https://cdn.nlark.com/yuque/0/2025/png/51372487/1763370345166-beaecf06-110f-4b8d-8e69-0ced954302c0.png)

# Get Started
```markdown
Run demo.m or muuflled.m for parameters selection.
```

# Contact
Thank you very much for your interest in our work.  
If you would like to get in touch, please feel free to reach our via:

+ Email: zhengkangyue@cug.edu.cn.

# 
